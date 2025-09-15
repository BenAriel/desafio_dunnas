package com.example.desafio_dunnas.domain.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.example.desafio_dunnas.domain.entity.Recepcionista;
import org.springframework.data.jpa.repository.EntityGraph;
import java.util.List;
import java.util.Optional;

@Repository
public interface RecepcionistaRepository extends JpaRepository<Recepcionista, Long> {

    @Override
    @EntityGraph(attributePaths = {"usuario", "setor"})
    List<Recepcionista> findAll();

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

    @EntityGraph(attributePaths = {"usuario", "setor"})
    Optional<Recepcionista> findByUsuarioId(Long usuarioId);
}
