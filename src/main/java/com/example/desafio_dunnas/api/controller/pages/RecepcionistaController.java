package com.example.desafio_dunnas.api.controller.pages;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/recepcionista")
@RequiredArgsConstructor
public class RecepcionistaController {

    @GetMapping({ "", "/" })
    public String recepcionistaHome() {
        return "recepcionista/recepcionista";
    }

}
