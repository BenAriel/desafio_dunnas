package com.example.desafio_dunnas.api.controller.pages;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.example.desafio_dunnas.domain.service.AdministradorService;
import com.example.desafio_dunnas.domain.service.RecepcionistaService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdministradorController {

    private final AdministradorService administradorService;
    private final RecepcionistaService recepcionistaService;

    @GetMapping({ "", "/" })
    public String adminHome() {
        return "admin/admin";
    }

    @GetMapping("/administradores")
    public String admin() {
        return "admin/admin";
    }

    @GetMapping("/administradores/novo-com-usuario")
    public String novoComUsuarioForm(Model model) {
        return "admin/administrador-form-com-usuario";
    }

    @GetMapping("clientes")
    public String getMethodName(@RequestParam String param) {
        return new String();
    }

    @PostMapping("/recepcionistas/salvar-com-usuario")
    public String salvar(
            @RequestParam("nome") String nome,
            @RequestParam("email") String email,
            @RequestParam("senha") String senha,
            @RequestParam("setorId") Long setorId,
            @RequestParam("matricula") String matricula,
            @RequestParam(value = "cpf", required = false) String cpf) {
        recepcionistaService.cadastrarUsuarioERecepcionista(nome, email, senha, setorId, matricula, cpf);
        return "redirect:/admin";
    }

    @PostMapping("/administradores/criar")
    public String salvarComUsuario(
            @RequestParam("nome") String nome,
            @RequestParam("email") String email,
            @RequestParam("senha") String senha,
            @RequestParam("matricula") String matricula,
            @RequestParam("cpf") String cpf) {
        administradorService.cadastrarUsuarioEAdministrador(nome, email, senha, matricula, cpf);
        return "redirect:/admin/administradores";
    }
}
