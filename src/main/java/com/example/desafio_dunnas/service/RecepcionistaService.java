package com.example.desafio_dunnas.service;

import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.example.desafio_dunnas.model.Recepcionista;
import com.example.desafio_dunnas.model.Usuario;
import com.example.desafio_dunnas.repository.RecepcionistaRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class RecepcionistaService {

    private final RecepcionistaRepository recepcionistaRepository;
    private final PasswordEncoder passwordEncoder;

    public List<Recepcionista> findAll() {
        return recepcionistaRepository.findAll();
    }

    public Page<Recepcionista> findAll(Pageable pageable) {
        return recepcionistaRepository.findAll(pageable);
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
        if (cpf == null || cpf.isBlank())
            throw new IllegalArgumentException("cpf é obrigatório");
        if (cpf.length() != 11)
            throw new IllegalArgumentException("cpf deve ter 11 dígitos");

        String senhaHash = passwordEncoder.encode(senhaPlano);
        recepcionistaRepository.criarUsuarioERecepcionista(nome, email, senhaHash, setorId, matricula, cpf);
    }

    public Optional<Recepcionista> getRecepcionistaLogado() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof Usuario usuario) {
            return recepcionistaRepository.findByUsuarioId(usuario.getId());
        }
        return Optional.empty();
    }

    public Recepcionista findById(Long id) {
        return recepcionistaRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Recepcionista não encontrado"));
    }

    public void atualizarRecepcionista(Long usuarioId, String nome, String email, String senhaPlano,
            Long setorId, String matricula, String cpf) {
        if (usuarioId == null)
            throw new IllegalArgumentException("usuarioId é obrigatório");
        if (nome == null || nome.isBlank())
            throw new IllegalArgumentException("nome é obrigatório");
        if (email == null || email.isBlank())
            throw new IllegalArgumentException("email é obrigatório");
        if (setorId == null)
            throw new IllegalArgumentException("setorId é obrigatório");
        if (matricula == null || matricula.isBlank())
            throw new IllegalArgumentException("matricula é obrigatória");
        if (cpf == null || cpf.isBlank())
            throw new IllegalArgumentException("cpf é obrigatório");
        if (cpf.length() != 11)
            throw new IllegalArgumentException("cpf deve ter 11 dígitos");
        String senhaHash = null;
        if (senhaPlano != null && !senhaPlano.isBlank()) {
            senhaHash = passwordEncoder.encode(senhaPlano);
        }
        recepcionistaRepository.atualizarUsuarioERecepcionista(usuarioId, nome, email, senhaHash,
                setorId, matricula, cpf);
    }

    public void excluirRecepcionista(Long recepcionistaId) {
        if (recepcionistaId == null)
            throw new IllegalArgumentException("recepcionistaId é obrigatório");
        recepcionistaRepository.excluirRecepcionistaComFechamento(recepcionistaId);
    }
}
