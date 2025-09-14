package com.example.desafio_dunnas.api.mapper;

import com.example.desafio_dunnas.api.dto.usuario.UsuarioResponse;
import com.example.desafio_dunnas.domain.entity.Usuario;

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
