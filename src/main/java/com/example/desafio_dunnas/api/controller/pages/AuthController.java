package com.example.desafio_dunnas.api.controller.pages;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.example.desafio_dunnas.domain.service.ClienteService;
import com.example.desafio_dunnas.domain.service.AuthenticatedUserDetailsService;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("")
@RequiredArgsConstructor
public class AuthController {
    private final AuthenticationManager authenticationManager;
    private final AuthenticatedUserDetailsService userDetailsService;
    private final ClienteService clienteService;

    @GetMapping("/login")
    public String login() {

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.isAuthenticated()
                && !(authentication instanceof AnonymousAuthenticationToken)) {
            for (GrantedAuthority au : authentication.getAuthorities()) {
                String role = au.getAuthority();
                if ("ROLE_ADMIN".equals(role)) {
                    return "redirect:/admin";
                }
                if ("ROLE_RECEPCIONISTA".equals(role)) {
                    return "redirect:/recepcionista";
                }
                if ("ROLE_CLIENTE".equals(role)) {
                    return "redirect:/cliente";
                }
            }
            // Sem papel conhecido: volta para login
            return "login";
        }
        return "login";
    }

    @GetMapping("/registrar")
    public String registrar() {
        return "registrar";
    }

    @PostMapping("/registrar")
    public String salvar(
            @RequestParam("nome") String nome,
            @RequestParam("email") String email,
            @RequestParam("senha") String senha,
            @RequestParam("telefone") String telefone,
            @RequestParam("profissao") String profissao) {

        // Criar o usuário
        clienteService.cadastrarUsuarioECliente(nome, email, senha, telefone, profissao);

        // Fazer login automático
        try {
            UserDetails userDetails = userDetailsService.loadUserByUsername(email);
            Authentication authentication = new UsernamePasswordAuthenticationToken(
                    userDetails, senha, userDetails.getAuthorities());
            Authentication authenticated = authenticationManager.authenticate(authentication);
            SecurityContextHolder.getContext().setAuthentication(authenticated);
        } catch (Exception e) {

            return "redirect:/login?success";
        }

        return "redirect:/cliente";
    }

}
