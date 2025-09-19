# Desafio Dunnas — Sistema de Gerenciamento de Reserva de Salas

## Sumário

- Visão geral do sistema
- Funcionalidades por papel (Admin, Recepcionista, Cliente)
- Arquitetura (Stack e MVC)
- Estrutura de pastas do projeto
- Modelo de dados (diagrama e tabelas)
- Regras de negócio: no Banco vs na Aplicação
- Fluxos principais (agendar, confirmar, finalizar, cancelar)
- Relatórios e caixa
- Setup: build, execução, credenciais, migrações
- Decisões de arquitetura
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

## Estrutura de pastas do projeto

- `src/main/java/com/example/desafio_dunnas/`
  - `controller/`: recebe requisições HTTP, aplica autorização, aciona serviços e retorna Views JSP.
  - `service/`: orquestra a lógica de aplicação, valida entradas básicas e delega operações críticas ao banco via repositórios.
  - `repository/`: interfaces Spring Data JPA; usa queries nativas para chamar procedures/functions do banco.
  - `model/` (ou `entity/`): mapeamento JPA das tabelas (Entidades e relacionamentos).
- `src/main/resources/`
  - `application.properties`: configurações do Spring, datasource, Flyway e ViewResolver.
  - `db/migration/`: scripts Flyway versionados (V1**...V28**) com schema, regras e dados de exemplo.
  - `static/`: arquivos estáticos servidos pela aplicação (imagens, JS, CSS).
  - `templates/`: recursos auxiliares (quando aplicável).
- `src/main/webapp/WEB-INF/jsp/`: páginas JSP separadas por papel (admin, recepcionista, cliente).
- `src/test/java/`: testes unitários/de integração (quando presentes).
- `pom.xml`: dependências e plugins Maven.
- `mvnw`, `mvnw.cmd`: wrappers Maven para build reprodutível.

Visão em árvore (parcial):

```text
desafio_dunnas/
├─ pom.xml
├─ mvnw / mvnw.cmd
├─ src/
│  ├─ main/
│  │  ├─ java/
│  │  │  └─ com/example/desafio_dunnas/
│  │  │     ├─ controller/
│  │  │     ├─ service/
│  │  │     ├─ repository/
│  │  │     └─ model/                 # entidades JPA
│  │  ├─ resources/
│  │  │  ├─ application.properties
│  │  │  ├─ db/migration/             # Flyway (V1__...V28__)
│  │  │  ├─ static/
│  │  │  │  ├─ images/
│  │  │  │  └─ js/
│  │  │  └─ templates/
│  │  └─ webapp/
│  │     └─ WEB-INF/jsp/              # JSPs (admin, recepcionista, cliente)
│  └─ test/
│     └─ java/                        # testes
└─ target/                            # artefatos gerados pelo Maven
```

Observações:

- JSPs ficam sob `WEB-INF` para evitar acesso direto por URL; são renderizadas via Controllers.
- Flyway organiza migrações incrementais e reproduz o ambiente (banco como fonte da verdade de regras críticas).
- Entidades JPA refletem o schema, mas o schema em si é controlado pelo Flyway.

Escolhas de arquitetura

- MVC no Spring: separa claramente camadas de entrada (controllers), orquestração (services) e acesso a dados (repositories), mantendo Views desacopladas.
- Regras críticas no banco: garante consistência, concorrência e atomicidade próximas aos dados; a aplicação chama procedures de alto nível.
- JSP + JSTL: escolha simples e integrada ao Spring Boot para o desafio; fácil renderização server-side.
- Flyway: versiona o banco, reproduzindo o ambiente com segurança e auditabilidade.
- Soft delete em entidades sensíveis (salas/setores) para preservar histórico sem quebrar FKs.

## Autenticação, formulários e validação

Autenticação (Spring Security)

- `SecurityConfig` define o `SecurityFilterChain` com regras de autorização por rota:
  - `/admin/**` apenas `ROLE_ADMIN`, `/recepcionista/**` apenas `ROLE_RECEPCIONISTA`, `/cliente/**` apenas `ROLE_CLIENTE`.
  - Páginas públicas: `/login`, `/registrar`, `/cliente/editar` e estáticos (`/css/**`, `/js/**`, `/static/**`).
- Login via formulário (`/login`) com parâmetros `email` e `password`.
- Pós-login redireciona por papel (handler customizado): Admin → `/admin`, Recepcionista → `/recepcionista`, Cliente → `/cliente`.
- Logout em `/logout` com redirecionamento para `/login?logout`.
- Recursos estáticos usam uma `SecurityFilterChain` dedicada, `STATELESS` e com CSRF desabilitado.

UserDetails e carregamento de usuário

- `Usuario` implementa `UserDetails`: `email` como username, `senha` como password, e a autoridade vem do `cargo.nome` (ex.: `ROLE_CLIENTE`).
- `AuthenticatedUserDetailsService` implementa `UserDetailsService` e carrega o usuário por email (`UsuarioRepository.findByEmail`) com `@EntityGraph` para buscar o `cargo` junto.

Autenticação programática

- `AuthService.authenticateAndEstablishSession` permite autenticar e criar sessão programaticamente (ex.: auto-login após cadastro), persistindo o `SecurityContext` na sessão HTTP via `SecurityContextRepository`.

Fluxo de login e registro (controllers e views)

- `AuthController` expõe:
  - `GET /login`: exibe a view de login; se já autenticado, redireciona conforme papel.
  - `GET /registrar`: prepara `RegistrarClienteForm` e renderiza view.
  - `POST /registrar`: valida o formulário; em sucesso, chama `ClienteService.cadastrarUsuarioECliente` e redireciona com flash message.
  - `GET/POST /cliente/editar`: fluxo público para atualização de dados do cliente.
- Views JSP esperadas: `login.jsp`, `registrar.jsp`, `cliente/editar-publico.jsp`.

Validação de formulários (Bean Validation)

- Form objects com Jakarta Bean Validation via anotações:
  - `RegistrarClienteForm`: `@NotBlank` (nome/email/senha/telefone), `@Email` (email), `@Size(min=6)` (senha), `@Pattern("\\d{11}")` (telefone)
  - `EditarClientePublicForm`: validações análogas, com `novaSenha` no lugar de `senha`
- Em caso de erro (`BindingResult.hasErrors()`), o controller reexibe a view com mensagens de validação.

Armazenamento de senhas

- `PasswordEncoder` é `BCryptPasswordEncoder` (em `SecurityConfig`).
- Seeds usam `crypt(..., gen_salt('bf',10))` no PostgreSQL para compatibilidade.

CSRF

- Para recursos estáticos, CSRF é desabilitado na filter chain dedicada.
- Para rotas com `formLogin`, o comportamento padrão do Spring se aplica (token CSRF incluído automaticamente quando necessário).

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

- `tb_cargos` (perfis/roles)
- `tb_usuarios` (nome, email, senha, ativo, role_id)
- `tb_administradores` (usuario_id, matricula, cpf)
- `tb_recepcionistas` (usuario_id, setor_id único, matricula, cpf)
- `tb_clientes` (usuario_id, telefone, profissao)
- `tb_setores` (nome, caixa, aberto, deleted_at, deleted_by)
- `tb_salas` (nome, valor_por_hora, capacidade_maxima, ativa, setor_id, deleted_at, deleted_by)
- `tb_agendamentos` (sala_id, cliente_id, data_hora_inicio/fim, valores, status, observacoes, datas)
- `tb_transacoes` (agendamento_id, valor, tipo, status, data_transacao, descricao, metodo_pagamento)
- `tb_historico_agendamentos` (agendamento_id, status_anterior, status_novo, data_mudanca, observacao)

### Diagrama ER

O diagrama entidade-relacionamento (extraído do PostgreSQL) está abaixo para referência rápida das relações entre tabelas:

![Diagrama ER](diagrama.png)

Principais relações:

- `tb_cargos` 1..N `tb_usuarios` (via role_id)
- `tb_usuarios` 1..1 `tb_administradores` (via usuario_id)
- `tb_usuarios` 1..1 `tb_recepcionistas` (via usuario_id)
- `tb_usuarios` 1..1 `tb_clientes` (via usuario_id)
- `tb_setores` 1..N `tb_salas` (via setor_id)
- `tb_setores` 1..1 `tb_recepcionistas` (via setor_id único)
- `tb_salas` 1..N `tb_agendamentos` (via sala_id)
- `tb_clientes` 1..N `tb_agendamentos` (via cliente_id)
- `tb_agendamentos` 1..N `tb_transacoes` (via agendamento_id)
- `tb_agendamentos` 1..N `tb_historico_agendamentos` (via agendamento_id)
- `tb_usuarios` 1..N `tb_setores` (via deleted_by)
- `tb_usuarios` 1..N `tb_salas` (via deleted_by)

Diagrama ER (Mermaid):

```mermaid
erDiagram
  tb_cargos ||--o{ tb_usuarios : "role_id"
  tb_usuarios ||--|| tb_administradores : "usuario_id"
  tb_usuarios ||--|| tb_recepcionistas : "usuario_id"
  tb_usuarios ||--|| tb_clientes : "usuario_id"

  tb_setores ||--o{ tb_salas : "setor_id"
  tb_setores ||--|| tb_recepcionistas : "setor_id (unique)"
  tb_salas ||--o{ tb_agendamentos : "sala_id"
  tb_clientes ||--o{ tb_agendamentos : "cliente_id"
  tb_agendamentos ||--o{ tb_transacoes : "agendamento_id"
  tb_agendamentos ||--o{ tb_historico_agendamentos : "agendamento_id"

  tb_usuarios ||--o{ tb_setores : "deleted_by"
  tb_usuarios ||--o{ tb_salas : "deleted_by"

  tb_cargos {
    bigint id PK
    varchar nome UNIQUE
  }
  tb_usuarios {
    bigint id PK
    varchar nome
    varchar email UNIQUE
    varchar senha
    boolean ativo
    bigint role_id FK
  }
  tb_administradores {
    bigint id PK
    bigint usuario_id FK UNIQUE
    varchar matricula UNIQUE
    varchar cpf UNIQUE
  }
  tb_recepcionistas {
    bigint id PK
    bigint usuario_id FK UNIQUE
    bigint setor_id FK UNIQUE
    varchar matricula UNIQUE
    varchar cpf UNIQUE
  }
  tb_clientes {
    bigint id PK
    bigint usuario_id FK UNIQUE
    varchar telefone UNIQUE
    varchar profissao
  }
  tb_setores {
    bigint id PK
    varchar nome UNIQUE
    numeric caixa
    boolean aberto
    timestamp deleted_at
    bigint deleted_by FK
  }
  tb_salas {
    bigint id PK
    varchar nome
    numeric valor_por_hora
    int capacidade_maxima
    boolean ativa
    bigint setor_id FK
    timestamp deleted_at
    bigint deleted_by FK
  }
  tb_agendamentos {
    bigint id PK
    bigint sala_id FK
    bigint cliente_id FK
    timestamp data_hora_inicio
    timestamp data_hora_fim
    numeric valor_total
    numeric valor_sinal
    numeric valor_restante
    varchar status
    varchar observacoes
    timestamp data_criacao
    timestamp data_confirmacao
    timestamp data_finalizacao
  }
  tb_transacoes {
    bigint id PK
    bigint agendamento_id FK
    numeric valor
    varchar tipo
    varchar status
    timestamp data_transacao
    varchar descricao
    varchar metodo_pagamento
  }
  tb_historico_agendamentos {
    bigint id PK
    bigint agendamento_id FK
    varchar status_anterior
    varchar status_novo
    timestamp data_mudanca
    varchar observacao
  }
```

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

- Disponível apenas para agendamentos `CONFIRMADO` cujo horário de início já passou, pois nestes casos como o agendamento não foi cancelado até o horario,quer dizer que ele iniciou.
- O sistema impede finalizar fora de ordem: se existir um agendamento anterior na mesma sala ainda `CONFIRMADO`, ele deve ser finalizado primeiro.
- O recepcionista pode finalizar o atendimento antes da hora de fim, mas aparecerá um modal de confirmação.
- Ao finalizar, o sistema registra o pagamento final (valor restante), marca a data de finalização e atualiza o caixa do setor.

4. Cancelamento

- Cliente ou recepcionista podem cancelar agendamentos em `SOLICITADO` a qualquer momento; o status vira `CANCELADO` sem movimentação financeira.
- Agendamentos `CONFIRMADO` podem ser cancelados apenas antes do horário de início; neste caso, o sistema registra um reembolso do sinal e atualiza o caixa do setor.
- Após o início do agendamento, o cancelamento não é permitido.

5. Abertura e fechamento de setor (Recepcionista)

- Abrir setor requer que exista um recepcionista responsável; ao abrir, as salas tornam-se disponíveis para novas solicitações e confirmações.
- Não é permitido fechar o setor se houver solicitações pendentes ou agendamentos `CONFIRMADO` no período futuro.
- Quando o setor está fechado, novas solicitações e confirmações dependentes do setor são bloqueadas.

6. Atendimento no balcão (Agendamento instantâneo)

- O recepcionista realiza um agendamento diretamente no balcão para início imediato ou próximo, sem passar pelo status `SOLICITADO`.
- O fluxo combina criação e confirmação em uma única ação: o sistema cria o agendamento, valida disponibilidade e regras do setor, e já confirma no mesmo passo.
- Efeitos: o status final fica como `CONFIRMADO`, o sinal é registrado, e o caixa do setor é atualizado. A finalização segue o fluxo normal posteriormente.

## Relatórios e caixa

- Caixa por setor é atualizado exclusivamente por trigger sobre `tb_transacoes` quando `status=CONFIRMADA`.
- Relatórios SQL prontos: agendamentos, transações, ocupação de sala, resumo financeiro do setor.

## Onde está cada regra (resumo)

- Conflito de agenda: `fn_verificar_conflito_agendamento` + trigger `tr_validar_conflito_agendamento`
- Confirmar: `pr_confirmar_agendamento` + `fn_validar_confirmacao_agendamento`
- Finalizar: `pr_finalizar_agendamento` + `fn_validar_finalizacao_agendamento` + `idx_ag_sala_status_inicio`
- Cancelar: `pr_cancelar_agendamento` + `fn_validar_cancelamento_agendamento`
- Caixa: trigger `tr_transacao_confirmada_credito` (crédito/débito)
- Abertura/Fechamento: `pr_abrir_setor`, `pr_fechar_setor`
- Soft delete: `pr_soft_delete_sala`, `pr_soft_delete_setor`, `pr_reativar_setor`

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
- Recepcionistas de exemplo (senha: `recepcionista123`):
  - `maria.silva@empresa.com`
  - `joao.santos@empresa.com`
  - `ana.costa@empresa.com`
- Clientes de exemplo (senha: `cliente123`):
  - `carlos.oliveira@email.com`
  - `fernanda.lima@email.com`
  - `roberto.alves@email.com`
  - `patricia.souza@email.com`

Obs.: as senhas são armazenadas com hash no banco, mas os valores acima são os utilizados para login.

Perfis e configurações:

- ViewResolver JSP: prefixo `/WEB-INF/jsp/` e sufixo `.jsp`
- Hibernate `ddl-auto=update` (o schema é garantido pelo Flyway; o update mantém JPA sincronizado)
