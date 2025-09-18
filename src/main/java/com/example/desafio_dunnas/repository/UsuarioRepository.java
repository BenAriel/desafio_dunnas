package com.example.desafio_dunnas.repository;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import com.example.desafio_dunnas.model.Usuario;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    /**
     * Busca usuário por e-mail carregando o cargo (perfil) associado.
     *
     * @param email e-mail único do usuário
     * @return usuário encontrado ou {@code null} se não existir
     * @pre {@code email} não deve ser nulo ou em branco
     * @post Leitura sem efeitos colaterais
     */
    @EntityGraph(attributePaths = { "cargo" })
    Usuario findByEmail(String email);

}
