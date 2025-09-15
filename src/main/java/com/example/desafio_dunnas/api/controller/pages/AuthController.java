package com.example.desafio_dunnas.api.controller.pages;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import jakarta.validation.Valid;

import com.example.desafio_dunnas.domain.service.ClienteService;
import com.example.desafio_dunnas.api.dto.auth.RegistrarClienteForm;
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
    public String registrar(Model model) {
        if (!model.containsAttribute("form")) {
            model.addAttribute("form", new RegistrarClienteForm());
        }
        return "registrar";
    }

    @PostMapping("/registrar")
    public String salvar(
            @Valid @ModelAttribute("form") RegistrarClienteForm form,
            BindingResult bindingResult,
            RedirectAttributes redirectAttributes) {

        if (bindingResult.hasErrors()) {
            return "registrar";
        }

        // Criar o usuário
        clienteService.cadastrarUsuarioECliente(form.getNome(), form.getEmail(), form.getSenha(), form.getTelefone(),
                form.getProfissao());

        // Fazer login automático
        try {
            UserDetails userDetails = userDetailsService.loadUserByUsername(form.getEmail());
            Authentication authentication = new UsernamePasswordAuthenticationToken(
                    userDetails, form.getSenha(), userDetails.getAuthorities());
            Authentication authenticated = authenticationManager.authenticate(authentication);
            SecurityContextHolder.getContext().setAuthentication(authenticated);
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error",
                    "Conta criada, mas não foi possível autenticar automaticamente. Faça login.");
            return "redirect:/login";
        }

        redirectAttributes.addFlashAttribute("success", "Conta criada e login efetuado com sucesso!");
        return "redirect:/cliente";
    }

}
