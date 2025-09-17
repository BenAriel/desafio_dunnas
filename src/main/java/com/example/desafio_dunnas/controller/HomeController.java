package com.example.desafio_dunnas.controller;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;

@Controller
public class HomeController {

    @GetMapping("/")
    public String home() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated()
                || authentication instanceof AnonymousAuthenticationToken) {
            return "login";
        }
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
}
