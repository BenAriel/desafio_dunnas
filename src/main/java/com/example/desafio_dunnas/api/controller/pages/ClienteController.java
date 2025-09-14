package com.example.desafio_dunnas.api.controller.pages;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

import org.springframework.web.bind.annotation.RequestMapping;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/cliente")
@RequiredArgsConstructor
public class ClienteController {

    @GetMapping({ "", "/" })
    public String clienteHome() {
        return "cliente/cliente";
    }
}
