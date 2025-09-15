package com.example.desafio_dunnas.api.dto.setor;

import java.math.BigDecimal;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class SetorForm {
    private Long id;

    @NotBlank(message = "Nome é obrigatório")
    private String nome;

    @DecimalMin(value = "0.0", inclusive = true, message = "Caixa não pode ser negativo")
    private BigDecimal caixa;

    private Boolean aberto;
}
