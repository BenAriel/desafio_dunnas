package com.example.desafio_dunnas.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.example.desafio_dunnas.model.Cliente;

@Repository
public interface ClienteRepository extends JpaRepository<Cliente, Long> {

    /**
     * Procedure: cria usuário e cliente de forma atômica.
     *
     * @param nome      Nome completo do cliente
     * @param email     E-mail único do usuário/cliente
     * @param senha     Hash da senha (codificada no service)
     * @param telefone  Telefone numérico com 11 dígitos (DDD + número)
     * @param profissao Profissão opcional do cliente
     * @pre Parâmetros validados no service (obrigatórios e formatos)
     * @post Usuário e cliente criados transacionalmente; em caso de erro, a
     *       transação é revertida
     * @throws DataIntegrityViolationException em caso de violação de integridade no
     *                                         banco (unicidade, FK etc.)
     * @throws DataAccessException             para outros erros de acesso a dados
     */
    @Transactional
    @Modifying
    @Query(value = "CALL pr_create_usuario_e_cliente(:p_nome, :p_email, :p_senha, :p_telefone, :p_profissao)", nativeQuery = true)
    void criarUsuarioECliente(
            @Param("p_nome") String nome,
            @Param("p_email") String email,
            @Param("p_senha") String senha,
            @Param("p_telefone") String telefone,
            @Param("p_profissao") String profissao);

    /**
     * Localiza a entidade Cliente associada ao id do usuário autenticado.
     *
     * @param usuarioId id do usuário dono do perfil de cliente
     * @return Optional contendo o cliente quando existir
     * @pre {@code usuarioId} não deve ser nulo
     * @post Nenhuma modificação em estado; apenas leitura
     */
    Optional<Cliente> findByUsuarioId(Long usuarioId);

    /**
     * Atualiza dados do usuário e cliente de forma atômica.
     *
     * Procedure: pr_update_usuario_e_cliente
     *
     * @param usuarioId ID do usuário a atualizar
     * @param nome      Novo nome
     * @param email     Novo e-mail (único)
     * @param senha     Novo hash de senha (pode ser nulo para manter)
     * @param telefone  Novo telefone (11 dígitos)
     * @param profissao Nova profissão (opcional)
     */
    @Transactional
    @Modifying
    @Query(value = "CALL pr_update_usuario_e_cliente(:p_usuario_id, :p_nome, :p_email, :p_senha, :p_telefone, :p_profissao)", nativeQuery = true)
    void atualizarUsuarioECliente(
            @Param("p_usuario_id") Long usuarioId,
            @Param("p_nome") String nome,
            @Param("p_email") String email,
            @Param("p_senha") String senha,
            @Param("p_telefone") String telefone,
            @Param("p_profissao") String profissao);
}
