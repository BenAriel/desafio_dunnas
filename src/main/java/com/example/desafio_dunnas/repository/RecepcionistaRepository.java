package com.example.desafio_dunnas.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.example.desafio_dunnas.model.Recepcionista;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import java.util.List;
import java.util.Optional;

@Repository
public interface RecepcionistaRepository extends JpaRepository<Recepcionista, Long> {

        @Override
        @EntityGraph(attributePaths = { "usuario", "setor" })
        /**
         * Retorna todos os recepcionistas carregando usuário e setor para evitar N+1.
         *
         * @return lista de recepcionistas com associações principais carregadas
         * @post Operação de leitura, não altera o estado do banco
         */
        List<Recepcionista> findAll();

        @EntityGraph(attributePaths = { "usuario", "setor" })
        /**
         * Retorna recepcionistas paginados, com usuário e setor carregados.
         *
         * @param pageable parâmetros de paginação e ordenação
         * @return página de recepcionistas
         * @pre {@code pageable} não deve ser nulo
         * @post Operação de leitura
         */
        Page<Recepcionista> findAll(Pageable pageable);

        /**
         * Procedure: cria usuário e recepcionista de forma atômica.
         *
         * @param nome      Nome do usuário
         * @param email     E-mail único
         * @param senha     Hash da senha
         * @param setorId   Id do setor vinculado ao recepcionista (deve ser único)
         * @param matricula Matrícula única
         * @param cpf       CPF único (11 dígitos)
         * @pre Parâmetros validados no service (obrigatórios, formatos e unicidade
         *      quando aplicável)
         * @post Usuário e recepcionista criados transacionalmente; rollback em caso de
         *       erro
         * @throws DataIntegrityViolationException em caso de violação de integridade no
         *                                         banco
         * @throws DataAccessException             para outros erros de acesso a dados
         */
        @Modifying
        @Transactional
        @Query(value = "CALL pr_create_usuario_e_recepcionista(:p_nome, :p_email, :p_senha, :p_setor_id, :p_matricula, :p_cpf)", nativeQuery = true)
        void criarUsuarioERecepcionista(
                        @Param("p_nome") String nome,
                        @Param("p_email") String email,
                        @Param("p_senha") String senha,
                        @Param("p_setor_id") Long setorId,
                        @Param("p_matricula") String matricula,
                        @Param("p_cpf") String cpf);

        @EntityGraph(attributePaths = { "usuario", "setor" })
        /**
         * Busca recepcionista pelo id do usuário vinculado.
         *
         * @param usuarioId id do usuário
         * @return Optional com o recepcionista encontrado
         * @pre {@code usuarioId} não deve ser nulo
         * @post Operação somente leitura
         */
        Optional<Recepcionista> findByUsuarioId(Long usuarioId);

        /**
         * Procedure: atualiza dados de usuário e recepcionista em uma única operação.
         *
         * @param usuarioId Id do usuário vinculado
         * @param nome      Novo nome
         * @param email     Novo e-mail
         * @param senha     Novo hash de senha (pode ser nulo para manter)
         * @param setorId   Id do setor a vincular
         * @param matricula Nova matrícula
         * @param cpf       Novo CPF
         * @pre Parâmetros validados no service (formato e unicidade)
         * @post Usuário e recepcionista atualizados transacionalmente; rollback em caso
         *       de erro
         * @throws DataIntegrityViolationException em caso de
         *                                         violação de
         *                                         integridade
         *                                         no banco
         * @throws DataAccessException             para outros erros de acesso a dados
         */
        @Modifying
        @Transactional
        @Query(value = "CALL pr_update_usuario_e_recepcionista(:p_usuario_id, :p_nome, :p_email, :p_senha, :p_setor_id, :p_matricula, :p_cpf)", nativeQuery = true)
        void atualizarUsuarioERecepcionista(
                        @Param("p_usuario_id") Long usuarioId,
                        @Param("p_nome") String nome,
                        @Param("p_email") String email,
                        @Param("p_senha") String senha,
                        @Param("p_setor_id") Long setorId,
                        @Param("p_matricula") String matricula,
                        @Param("p_cpf") String cpf);

        /**
         * Procedure: exclui recepcionista aplicando regras de fechamento/auditoria
         * conforme necessário.
         *
         * @param recepcionistaId Id do recepcionista a excluir
         * @pre {@code recepcionistaId} válido e existente; validações de regra
         *      realizadas no service
         * @post Recepcionista excluído e efeitos colaterais aplicados pela procedure;
         *       rollback em caso de erro
         * @throws DataIntegrityViolationException em caso de
         *                                         violação de
         *                                         integridade
         *                                         no banco
         * @throws DataAccessException             para outros
         *                                         erros de
         *                                         acesso a
         *                                         dados
         */
        @Modifying
        @Transactional
        @Query(value = "CALL pr_delete_recepcionista(:p_recepcionista_id)", nativeQuery = true)
        void excluirRecepcionistaComFechamento(@Param("p_recepcionista_id") Long recepcionistaId);
}
