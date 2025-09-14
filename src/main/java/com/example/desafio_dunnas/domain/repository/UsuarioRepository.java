package com.example.desafio_dunnas.domain.repository;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import com.example.desafio_dunnas.domain.entity.Usuario;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    @EntityGraph(attributePaths = { "cargo" })
    Usuario findByEmail(String email);

}
