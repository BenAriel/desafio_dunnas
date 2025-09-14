package com.example.desafio_dunnas.domain.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.example.desafio_dunnas.domain.entity.Cliente;

@Repository
public interface ClienteRepository extends JpaRepository<Cliente, Long> {

    @Transactional
    @Modifying
    @Query(value = "CALL pr_create_usuario_e_cliente(:p_nome, :p_email, :p_senha, :p_telefone, :p_profissao)", nativeQuery = true)
    void criarUsuarioECliente(
            @Param("p_nome") String nome,
            @Param("p_email") String email,
            @Param("p_senha") String senha,
            @Param("p_telefone") String telefone,
            @Param("p_profissao") String profissao);
}
