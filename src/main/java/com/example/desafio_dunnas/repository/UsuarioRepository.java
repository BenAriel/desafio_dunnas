package com.example.desafio_dunnas.repository;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import com.example.desafio_dunnas.model.Usuario;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    @EntityGraph(attributePaths = { "cargo" })
    Usuario findByEmail(String email);

}
