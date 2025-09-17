package com.example.desafio_dunnas.form.sala;

import java.math.BigDecimal;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SalaForm {

    private Long id;

    @NotBlank(message = "Nome é obrigatório")
    private String nome;

    @NotNull(message = "Valor por hora é obrigatório")
    @DecimalMin(value = "0.0", inclusive = true, message = "Valor por hora deve ser positivo")
    private BigDecimal valorPorHora;

    @NotNull(message = "Capacidade é obrigatória")
    @Min(value = 1, message = "Capacidade mínima é 1")
    private Integer capacidadeMaxima;

    @NotNull(message = "Selecione um setor")
    private Long setorId;

    private Boolean ativa = true;

}
