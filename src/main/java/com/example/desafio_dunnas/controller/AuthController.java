package com.example.desafio_dunnas.controller;

import org.springframework.stereotype.Controller;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import jakarta.validation.Valid;

import com.example.desafio_dunnas.config.DbErrorMessageResolver;
import com.example.desafio_dunnas.form.auth.RegistrarClienteForm;
import com.example.desafio_dunnas.form.auth.EditarClientePublicForm;
import com.example.desafio_dunnas.service.ClienteService;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.authentication.AnonymousAuthenticationToken;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("")
@RequiredArgsConstructor
public class AuthController {

    private final ClienteService clienteService;

    @GetMapping("/login")
    public String login(Model model, HttpServletRequest request) {

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.isAuthenticated()
                && !(authentication instanceof AnonymousAuthenticationToken)) {

            if ((model != null && model.containsAttribute("error"))
                    || request.getParameter("error") != null
                    || request.getParameter("logout") != null) {
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

        try {
            clienteService.cadastrarUsuarioECliente(form.getNome(), form.getEmail(), form.getSenha(),
                    form.getTelefone(),
                    form.getProfissao());

            redirectAttributes.addFlashAttribute("success", "Conta criada com sucesso! Você já pode fazer login.");

        } catch (Exception e) {
            bindingResult.reject("error", DbErrorMessageResolver.resolve(e));
            return "registrar";
        }

        return "redirect:/login";
    }

    @GetMapping("/cliente/editar")
    public String editarPublico(Model model) {
        if (!model.containsAttribute("form")) {
            model.addAttribute("form", new EditarClientePublicForm());
        }
        return "cliente/editar-publico";
    }

    @PostMapping("/cliente/editar")
    public String salvarEdicaoPublica(
            @Valid @ModelAttribute("form") EditarClientePublicForm form,
            BindingResult bindingResult,
            RedirectAttributes redirectAttributes) {

        if (bindingResult.hasErrors()) {
            return "cliente/editar-publico";
        }

        try {
            clienteService.atualizarCadastroPublico(form.getEmail(), form.getNome(), form.getTelefone(),
                    form.getProfissao(), form.getNovaSenha());
            redirectAttributes.addFlashAttribute("success", "Dados atualizados com sucesso. Você já pode fazer login.");
            return "redirect:/login";
        } catch (Exception e) {
            bindingResult.reject("error", DbErrorMessageResolver.resolve(e));
            return "cliente/editar-publico";
        }
    }

}
