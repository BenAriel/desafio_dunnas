package com.example.desafio_dunnas.api.mapper;

import com.example.desafio_dunnas.form.usuario.UsuarioResponse;
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
