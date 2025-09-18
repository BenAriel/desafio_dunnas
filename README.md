# Desafio Dunnas — Sistema de Gerenciamento de Reserva de Salas

## Sumário

- Visão geral do sistema
- Funcionalidades por papel (Admin, Recepcionista, Cliente)
- Arquitetura (Stack e MVC)
- Modelo de dados (diagrama e tabelas)
- Regras de negócio: no Banco vs na Aplicação
- Fluxos principais (agendar, confirmar, finalizar, cancelar)
- Relatórios e caixa
- Setup: build, execução, credenciais, migrações
- Decisões de arquitetura
- Endpoints/Views principais
- Como contribuir e próximos passos

---

## Visão geral

Este projeto implementa um sistema de reservas de salas com três papéis: `Administrador`, `Recepcionista` e `Cliente`. A aplicação usa Spring Boot (Java) com JSP para views e PostgreSQL com Flyway para versionamento do banco. Mais de 50% da lógica de negócio está implementada diretamente no banco de dados (functions, procedures e triggers), conforme os requisitos do desafio.

## Stack e arquitetura

- Backend: `Java 21 + Spring Boot 3`
- View: `JSP (Jakarta JSP + JSTL)`
- Banco de dados: `PostgreSQL`
- Versionamento de BD: `Flyway` com scripts em `src/main/resources/db/migration`
- Segurança: `Spring Security` com autenticação baseada em papéis
- Build/execução: `Maven`

Padrão MVC:

- Controllers em `src/main/java/com/example/desafio_dunnas/controller`
- Services em `.../service` delegam operações de negócio para o banco via repositórios
- Repositories em `.../repository` (JPA + queries nativas para chamar procedures)
- Models (JPA Entities) em `.../model`
- Views JSP em `src/main/webapp/WEB-INF/jsp`

## Funcionalidades por papel

- Administrador
  - CRUD de setores, salas e recepcionistas
  - Soft delete de setores/salas; reativação de setor
  - Visualização e relatórios globais
- Recepcionista
  - Abrir/fechar setor (com regras de integridade)
  - Gerenciar agendamentos do seu setor: listar, confirmar, finalizar, cancelar (com regras)
  - Agendamento instantâneo (cria + confirma)
  - Relatórios do setor e visão do caixa
- Cliente
  - Autocadastro e login
  - Visualização de setores/salas disponíveis
  - Solicitação de agendamento (status `SOLICITADO` até a confirmação)

## Modelo de dados (resumo)

Tabelas centrais:

- `tb_cargos`, `tb_usuarios` (autenticação/roles) + `tb_administradores`, `tb_recepcionistas`, `tb_clientes`
- `tb_setores` (caixa, aberto/fechado, soft delete)
- `tb_salas` (valor_por_hora, capacidade, ativa, setor_id, soft delete)
- `tb_agendamentos` (sala, cliente, início/fim, valores, status, datas)
- `tb_transacoes` (agendamento, valor, tipo `SINAL|PAGAMENTO_FINAL|REEMBOLSO`, status)
- `tb_historico_agendamentos` (auditoria de mudanças de status)

## Regras de negócio (Banco vs Aplicação)

Principais regras no Banco (functions/procedures/triggers):

- Criação/validação de agendamentos: `pr_create_agendamento`, `fn_verificar_sala_disponivel`, `fn_verificar_conflito_agendamento`
- Confirmação: `pr_confirmar_agendamento` com criação/validação de `SINAL` e timestamp; `fn_validar_confirmacao_agendamento`
- Finalização: `pr_finalizar_agendamento` cria `PAGAMENTO_FINAL` confirmado; `fn_validar_finalizacao_agendamento` impede finalização antes do início e fora de ordem
- Cancelamento: `pr_cancelar_agendamento` permite SOLICITADO e CONFIRMADO antes do início; gera `REEMBOLSO`
- Crédito/débito de caixa por transações confirmadas: trigger `tr_transacao_confirmada_credito` credita (SINAL/PAGAMENTO_FINAL) ou debita (REEMBOLSO) diretamente em `tb_setores`
- Abertura/fechamento de setor: `pr_abrir_setor`, `pr_fechar_setor` (bloqueia fechar com agendamentos ativos)
- Soft delete: `pr_soft_delete_sala`, `pr_soft_delete_setor`, `pr_reativar_setor`; valida ausência de agendamentos ativos para excluir; atualização de validations para ignorar registros soft deleted
- Cálculos financeiros: `fn_calcular_valor_total_por_horas` (proporcional por minuto), `fn_calcular_valor_sinal_por_horas`, `fn_calcular_valor_restante_por_horas`
- Auditoria: `tr_historico_agendamento` grava mudanças de status e `tr_timestamp_agendamento` preenche datas
- Relatórios: `fn_relatorio_agendamentos_setor`, `fn_relatorio_transacoes_setor`, `fn_resumo_financeiro_setor`, `fn_estatisticas_ocupacao_sala`

Regras na Aplicação (Spring):

- Autenticação/Autorização via Spring Security (papéis: ADMIN, RECEPCIONISTA, CLIENTE)
- Orquestração de telas/fluxos (Controllers + Services)
- Consultas paginadas e listagens (JPA Repositories)
- Validações simples de formulário antes de delegar a procedures
- Chamada das procedures nativas para operações sensíveis (criar, confirmar, finalizar, cancelar, abrir/fechar)

Com isso, >50% da lógica de negócio reside no banco, atendendo ao desafio.

## Fluxos principais

1. Solicitação de agendamento (Cliente)

- O cliente escolhe uma sala ativa de um setor aberto e informa data/hora de início e fim.
- O sistema valida: horários no futuro, fim depois do início e ausência de conflito com agendamentos já confirmados para a mesma sala.
- Se tudo estiver ok, o agendamento é criado com status `SOLICITADO` e os valores são calculados proporcionalmente ao período (total, sinal de 50% e restante).

2. Confirmação de agendamento (Recepcionista)

- O recepcionista vê as solicitações do seu setor e pode confirmar agendamentos que ainda não começaram e cujo setor esteja aberto.
- Ao confirmar, o status muda para `CONFIRMADO`, o pagamento de sinal é registrado e a data de confirmação é gravada. O caixa do setor é atualizado com o valor do sinal.
- Não é possível confirmar se o horário de início já passou ou se o setor estiver fechado.

3. Finalização da utilização (Recepcionista)

- Disponível apenas para agendamentos `CONFIRMADO` cujo horário de início já passou.
- O sistema impede finalizar fora de ordem: se existir um agendamento anterior na mesma sala ainda `CONFIRMADO`, ele deve ser finalizado primeiro.
- Ao finalizar, o sistema registra o pagamento final (valor restante), marca a data de finalização e atualiza o caixa do setor.

4. Cancelamento

- Cliente ou recepcionista podem cancelar agendamentos em `SOLICITADO` a qualquer momento; o status vira `CANCELADO` sem movimentação financeira.
- Agendamentos `CONFIRMADO` podem ser cancelados apenas antes do horário de início; neste caso, o sistema registra um reembolso do sinal e atualiza o caixa do setor.
- Após o início do agendamento, o cancelamento não é permitido.

5. Abertura e fechamento de setor (Recepcionista)

- Abrir setor requer que exista um recepcionista responsável; ao abrir, as salas tornam-se disponíveis para novas solicitações e confirmações.
- Não é permitido fechar o setor se houver solicitações pendentes ou agendamentos `CONFIRMADO` no período futuro.
- Quando o setor está fechado, novas solicitações e confirmações dependentes do setor são bloqueadas.

## Relatórios e caixa

- Caixa por setor é atualizado exclusivamente por trigger sobre `tb_transacoes` quando `status=CONFIRMADA`.
- Relatórios SQL prontos: agendamentos, transações, ocupação de sala, resumo financeiro do setor.

## Setup (Windows)

Pré-requisitos:

- PostgreSQL 13+ rodando localmente
- Java 21, Maven 3.9+

Banco de dados:

- Crie o banco `reservas_db` e um usuário com acesso. Ajuste as credenciais em `src/main/resources/application.properties` se necessário.

Execução (linha de comando PowerShell):

```powershell
# Compilar e executar
./mvnw.cmd clean spring-boot:run
```

A aplicação sobe em `http://localhost:8080`.

Flyway:

- Executa automaticamente ao subir a aplicação (spring.flyway.enabled=true)
- Também pode rodar via Maven:

```powershell
./mvnw.cmd -Dflyway.url="jdbc:postgresql://localhost:5432/reservas_db" -Dflyway.user=postgres -Dflyway.password=SUASENHA flyway:migrate
```

Credenciais iniciais (seeds):

- Admin padrão: email `admin@local.test` / senha `admin123`
- Recepcionistas e clientes de exemplo são criados no V8 (senhas: `recepcionista123` e `cliente123`)

Perfis e configurações:

- ViewResolver JSP: prefixo `/WEB-INF/jsp/` e sufixo `.jsp`
- Hibernate `ddl-auto=update` (o schema é garantido pelo Flyway; o update mantém JPA sincronizado)

## Decisões de arquitetura

- Banco como fonte da verdade de regras críticas: concorrência, integridade temporal e financeira centralizadas em SQL/PLpgSQL, com procedures transacionais.
- Triggers de transações centralizam o caixa do setor, evitando divergência entre eventos de agendamento e financeiro.
- Soft delete em `salas` e `setores` preserva histórico e impede quebra de FKs; procedures cuidam de consistência.
- Cálculo por minuto (arredondado a 2 casas) melhora precisão frente a períodos não múltiplos de hora.

## Endpoints/Views principais

- Recepcionista
  - `GET /recepcionista` (home do setor)
  - `GET /recepcionista/agendamentos` (listar por status)
  - `POST /recepcionista/agendamentos/confirmar|finalizar|cancelar`
  - `GET|POST /recepcionista/agendamentos/instantaneo` (criar+confirmar)
  - `GET /recepcionista/setor/abrir|fechar`
- Cliente
  - `GET /cliente` (home)
  - `GET /cliente/setores`, `GET /cliente/salas`, `GET|POST /cliente/solicitar-agendamento`
- Admin
  - `GET /admin` (home)
  - CRUD de setores/salas/recepcionistas (JSPs em `/WEB-INF/jsp/admin/*`)

## Onde está cada regra (resumo)

- Conflito de agenda: `fn_verificar_conflito_agendamento` + trigger `tr_validar_conflito_agendamento`
- Confirmar: `pr_confirmar_agendamento` + `fn_validar_confirmacao_agendamento`
- Finalizar: `pr_finalizar_agendamento` + `fn_validar_finalizacao_agendamento` + `idx_ag_sala_status_inicio`
- Cancelar: `pr_cancelar_agendamento` + `fn_validar_cancelamento_agendamento`
- Caixa: trigger `tr_transacao_confirmada_credito` (crédito/débito)
- Abertura/Fechamento: `pr_abrir_setor`, `pr_fechar_setor`
- Soft delete: `pr_soft_delete_sala`, `pr_soft_delete_setor`, `pr_reativar_setor`

## Como e onde cada funcionalidade foi aplicada (resumo prático)

O projeto segue MVC no Spring e centraliza as regras críticas no banco (procedures, functions e triggers). Abaixo, um mapa simples.

O que é uma procedure?

- Uma procedure (stored procedure) é um bloco de código SQL/PLpgSQL armazenado no banco que você executa com `CALL nome_procedure(parametros)`. Ela permite agrupar várias operações (validações, inserções/atualizações, cálculos) numa transação atômica e próxima dos dados, reduzindo problemas de concorrência e garantindo regras mesmo quando chamadas de diferentes pontos da aplicação.

Como chamamos procedures aqui?

- Pela camada de repositório (Spring Data JPA) com `@Query(nativeQuery = true)` e `CALL ...`. Ex.: `AgendamentoRepository.criarAgendamento`, `confirmarAgendamento`, `finalizarAgendamento`, `cancelarAgendamento`; `SetorRepository.abrirSetor`, `fecharSetor`.

Funcionalidade: Solicitar agendamento (Cliente)

- Controller: `ClienteController` (`/cliente/agendamentos/solicitar`)
- Service: `AgendamentoService.criarAgendamento`
- Repository: `AgendamentoRepository.criarAgendamento`
- Banco: `pr_create_agendamento` (V13/V24) faz validações (setor aberto, sala ativa, tempo futuro), verifica conflito via `fn_verificar_sala_disponivel`/`fn_verificar_conflito_agendamento` e calcula `valor_total/sinal/restante` por minuto (`fn_calcular_valor_*`). Por que no BD? Para garantir consistência e concorrência controlada na origem.

Funcionalidade: Confirmar agendamento (Recepcionista e instantâneo)

- Controller: `RecepcionistaController` (`POST /agendamentos/confirmar` e fluxo instantâneo)
- Service: `AgendamentoService.confirmarAgendamento`
- Repository: `AgendamentoRepository.confirmarAgendamento`
- Banco: `pr_confirmar_agendamento` (V17/V24) valida `SOLICITADO` e setor aberto (`fn_validar_confirmacao_agendamento`); cria/garante transação `SINAL` já `CONFIRMADA`; trigger em `tb_transacoes` credita o caixa. Por que no BD? Para evitar confirmações incorretas e centralizar o crédito do caixa.

Funcionalidade: Finalizar agendamento (Recepcionista)

- Controller: `RecepcionistaController` (`POST /agendamentos/finalizar`)
- Service: `AgendamentoService.finalizarAgendamento`
- Repository: `AgendamentoRepository.finalizarAgendamento`
- Banco: `pr_finalizar_agendamento` (V21/V28) valida que já iniciou e que não existe confirmado anterior na mesma sala (ordem). Cria `PAGAMENTO_FINAL` `CONFIRMADA`; trigger credita caixa. Por que no BD? Para manter integridade temporal e financeira.

Funcionalidade: Cancelar agendamento (Cliente/Recepcionista)

- Controllers: `ClienteController` (`POST /cliente/agendamentos/cancelar`), `RecepcionistaController` (`POST /recepcionista/agendamentos/cancelar`)
- Service: `AgendamentoService.cancelarAgendamento`
- Repository: `AgendamentoRepository.cancelarAgendamento`
- Banco: `pr_cancelar_agendamento` (V23) — se `SOLICITADO`, só troca para `CANCELADO`; se `CONFIRMADO` e antes do início, cancela e gera `REEMBOLSO` `CONFIRMADA`; trigger debita caixa. Por que no BD? Para garantir política de cancelamento e reflexo automático no caixa.

Funcionalidade: Abrir/Fechar setor (Recepcionista)

- Controller: `RecepcionistaController` (`/setor/abrir` e `/setor/fechar`)
- Service: `SetorService.abrirSetor`/`fecharSetor`
- Repository: `SetorRepository.abrirSetor`/`fecharSetor`
- Banco: `pr_abrir_setor` (V11) exige recepcionista; `pr_fechar_setor` (V24) bloqueia se houver `SOLICITADO/CONFIRMADO` no setor. Por que no BD? Para impedir estados inválidos independente da origem da chamada.

Funcionalidade: Soft delete de sala e setor (Admin)

- Services/Repos: `SetorService.softDeleteSetor`/`reativarSetor`; `SalaService` análogo para sala
- Banco: `pr_soft_delete_setor` e `pr_soft_delete_sala` (V25) verificam inexistência de agendamentos ativos, marcam `deleted_at` e ajustam vínculos; functions/consultas ignoram soft-deletados. Por que no BD? Para manter histórico e integridade de FKs.

Funcionalidade: Caixa do setor

- Banco: trigger `tr_transacao_confirmada_credito` (V22/V23) atualiza `tb_setores.caixa` quando uma transação `SINAL`/`PAGAMENTO_FINAL`/`REEMBOLSO` muda (ou nasce) com `status=CONFIRMADA` (INSERT/UPDATE). Por que no BD? Para consistência financeira automática.

Funcionalidade: Relatórios

- Service: `RelatorioService` (consome consultas/funções do BD)
- Banco: `fn_relatorio_agendamentos_setor`, `fn_relatorio_transacoes_setor`, `fn_resumo_financeiro_setor`, `fn_estatisticas_ocupacao_sala` (V12). Por que no BD? Para performance e reutilização de lógica SQL.
