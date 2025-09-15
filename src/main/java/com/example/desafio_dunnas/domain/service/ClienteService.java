package com.example.desafio_dunnas.domain.service;

import java.util.List;
import java.util.Optional;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.example.desafio_dunnas.domain.entity.Cliente;
import com.example.desafio_dunnas.domain.entity.Usuario;
import com.example.desafio_dunnas.domain.repository.ClienteRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ClienteService {

    private final ClienteRepository clienteRepository;
    private final PasswordEncoder passwordEncoder;

    public List<Cliente> findAll() {
        return clienteRepository.findAll();
    }

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

    public Optional<Cliente> getClienteLogado() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof Usuario) {
            Usuario usuario = (Usuario) authentication.getPrincipal();
            return clienteRepository.findByUsuarioId(usuario.getId());
        }
        return Optional.empty();
    }
}
