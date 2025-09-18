package com.example.desafio_dunnas.service;

import java.util.Optional;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.context.SecurityContextRepository;
import org.springframework.stereotype.Service;

import com.example.desafio_dunnas.dto.usuario.UsuarioResponse;
import com.example.desafio_dunnas.mapper.UsuarioMapper;
import com.example.desafio_dunnas.model.Usuario;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final SecurityContextRepository securityContextRepository;

    public UsuarioResponse authenticateAndEstablishSession(String email, String rawPassword,
            HttpServletRequest request,
            HttpServletResponse response) {
        Authentication authRequest = new UsernamePasswordAuthenticationToken(email, rawPassword);
        Authentication authResult = authenticationManager.authenticate(authRequest);

        SecurityContext context = SecurityContextHolder.createEmptyContext();
        context.setAuthentication(authResult);
        SecurityContextHolder.setContext(context);
        securityContextRepository.saveContext(context, request, response);
        request.getSession(true);
        return UsuarioMapper.toDTO((Usuario) authResult.getPrincipal());
    }

    public Optional<UsuarioResponse> getUsuarioLogado() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof Usuario usuario) {
            return Optional.of(UsuarioMapper.toDTO(usuario));
        }
        return Optional.empty();
    }

    public Long requireUsuarioId() {
        return getUsuarioLogado()
                .map(UsuarioResponse::getUserId)
                .orElseThrow(() -> new IllegalStateException("Usuário não autenticado"));
    }
}
