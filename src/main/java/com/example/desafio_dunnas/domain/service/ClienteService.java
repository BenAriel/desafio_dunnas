package com.example.desafio_dunnas.domain.service;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.example.desafio_dunnas.domain.repository.ClienteRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ClienteService {

    private final ClienteRepository clienteRepository;
    private final PasswordEncoder passwordEncoder;

    public void cadastrarUsuarioECliente(
            String nome, String email, String senhaPlano, String telefone, String profissao) {
        if (nome == null || nome.isBlank())
            throw new IllegalArgumentException("nome é obrigatório");
        if (email == null || email.isBlank())
            throw new IllegalArgumentException("email é obrigatório");
        if (senhaPlano == null || senhaPlano.isBlank())
            throw new IllegalArgumentException("senha é obrigatória");

        String senhaHash = passwordEncoder.encode(senhaPlano);
        clienteRepository.criarUsuarioECliente(nome, email, senhaHash, telefone, profissao);
    }
}
