package com.example.desafio_dunnas.form.administrador;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AdministradorForm {

    @NotBlank(message = "Nome é obrigatório")
    private String nome;

    @Email(message = "Email inválido")
    @NotBlank(message = "Email é obrigatório")
    private String email;

    @NotBlank(message = "Senha é obrigatória")
    private String senha;

    @NotBlank(message = "Matrícula é obrigatória")
    private String matricula;

    @Pattern(regexp = "^$|\\d{11}", message = "CPF deve ter 11 dígitos")
    private String cpf;
}
