package com.example.desafio_dunnas.domain.service;

import java.util.List;
import java.util.Optional;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.example.desafio_dunnas.domain.entity.Recepcionista;
import com.example.desafio_dunnas.domain.entity.Usuario;
import com.example.desafio_dunnas.domain.repository.RecepcionistaRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class RecepcionistaService {

    private final RecepcionistaRepository recepcionistaRepository;
    private final PasswordEncoder passwordEncoder;

    public List<Recepcionista> findAll() {
        return recepcionistaRepository.findAll();
    }

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

    public Optional<Recepcionista> getRecepcionistaLogado() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof Usuario) {
            Usuario usuario = (Usuario) authentication.getPrincipal();
            return recepcionistaRepository.findByUsuarioId(usuario.getId());
        }
        return Optional.empty();
    }
}
