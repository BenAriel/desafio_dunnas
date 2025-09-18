package com.example.desafio_dunnas.service;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.example.desafio_dunnas.repository.AdministradorRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AdministradorService {

    private final AdministradorRepository adminRepository;
    private final PasswordEncoder passwordEncoder;

    public void cadastrarUsuarioEAdministrador(
            String nome, String email, String senhaPlano, String matricula, String cpf) {
        if (nome == null || nome.isBlank())
            throw new IllegalArgumentException("nome é obrigatório");
        if (email == null || email.isBlank())
            throw new IllegalArgumentException("email é obrigatório");
        if (senhaPlano == null || senhaPlano.isBlank())
            throw new IllegalArgumentException("senha é obrigatória");
        if (matricula == null || matricula.isBlank())
            throw new IllegalArgumentException("matricula é obrigatória");
        if (cpf == null || cpf.isBlank())
            throw new IllegalArgumentException("cpf é obrigatório");
        if (cpf.length() != 11)
            throw new IllegalArgumentException("cpf deve ter 11 dígitos");
        if (!cpf.chars().allMatch(Character::isDigit))
            throw new IllegalArgumentException("cpf deve conter apenas dígitos numéricos");

        String senhaHash = passwordEncoder.encode(senhaPlano);
        adminRepository.criarUsuarioEAdministrador(nome, email, senhaHash, matricula, cpf);
    }
}
