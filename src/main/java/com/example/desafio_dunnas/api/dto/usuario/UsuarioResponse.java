package com.example.desafio_dunnas.api.dto.usuario;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class UsuarioResponse {
    Long userId;
    String name;
    String email;
    String role;
}
