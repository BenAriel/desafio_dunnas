package com.example.desafio_dunnas.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.example.desafio_dunnas.model.Administrador;

@Repository
public interface AdministradorRepository extends JpaRepository<Administrador, Long> {
    @Modifying
    @Transactional
    @Query(value = "CALL pr_create_usuario_e_administrador(:p_nome, :p_email, :p_senha, :p_matricula, :p_cpf)", nativeQuery = true)
    void criarUsuarioEAdministrador(
            @Param("p_nome") String nome,
            @Param("p_email") String email,
            @Param("p_senha") String senha,
            @Param("p_matricula") String matricula,
            @Param("p_cpf") String cpf);
}
