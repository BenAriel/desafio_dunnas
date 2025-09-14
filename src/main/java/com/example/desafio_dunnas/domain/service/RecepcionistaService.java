package com.example.desafio_dunnas.domain.service;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.example.desafio_dunnas.domain.repository.RecepcionistaRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class RecepcionistaService {

    private final RecepcionistaRepository recepcionistaRepository;
    private final PasswordEncoder passwordEncoder;

    public void cadastrarUsuarioERecepcionista(
            String nome, String email, String senhaPlano, Long setorId, String matricula, String cpf) {
        if (nome == null || nome.isBlank())
            throw new IllegalArgumentException("nome é obrigatório");
        if (email == null || email.isBlank())
            throw new IllegalArgumentException("email é obrigatório");
        if (senhaPlano == null || senhaPlano.isBlank())
            throw new IllegalArgumentException("senha é obrigatória");
        if (setorId == null)
            throw new IllegalArgumentException("setorId é obrigatório");
        if (matricula == null || matricula.isBlank())
            throw new IllegalArgumentException("matricula é obrigatória");
        if (cpf != null && cpf.length() != 11)
            throw new IllegalArgumentException("cpf deve ter 11 dígitos");

        String senhaHash = passwordEncoder.encode(senhaPlano);
        recepcionistaRepository.criarUsuarioERecepcionista(nome, email, senhaHash, setorId, matricula, cpf);
    }
}
