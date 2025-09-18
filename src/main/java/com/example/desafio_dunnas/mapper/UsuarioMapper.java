package com.example.desafio_dunnas.mapper;

import com.example.desafio_dunnas.dto.usuario.UsuarioResponse;
import com.example.desafio_dunnas.model.Usuario;

public class UsuarioMapper {

    public static UsuarioResponse toDTO(Usuario usuario) {
        if (usuario == null) {
            return null;
        }

        return new UsuarioResponse(
                usuario.getId(),
                usuario.getNome(),
                usuario.getEmail(),
                usuario.getCargo().getNome());
    }
}
