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
    List<Recepcionista> findAll();

    @EntityGraph(attributePaths = { "usuario", "setor" })
    Page<Recepcionista> findAll(Pageable pageable);

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
    Optional<Recepcionista> findByUsuarioId(Long usuarioId);

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

    @Modifying
    @Transactional
    @Query(value = "CALL pr_delete_recepcionista(:p_recepcionista_id)", nativeQuery = true)
    void excluirRecepcionistaComFechamento(@Param("p_recepcionista_id") Long recepcionistaId);
}
