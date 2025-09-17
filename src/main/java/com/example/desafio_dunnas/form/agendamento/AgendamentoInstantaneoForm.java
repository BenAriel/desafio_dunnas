package com.example.desafio_dunnas.form.agendamento;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AgendamentoInstantaneoForm {
    @NotNull(message = "Sala é obrigatória")
    private Long salaId;

    @NotNull(message = "Cliente é obrigatório")
    private Long clienteId;

    @NotBlank(message = "Data/hora de início é obrigatória")
    @Pattern(regexp = "\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}", message = "Formato de data/hora inválido")
    private String dataHoraInicio;

    @NotBlank(message = "Data/hora de fim é obrigatória")
    @Pattern(regexp = "\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}", message = "Formato de data/hora inválido")
    private String dataHoraFim;

    private String observacoes;

    @NotNull(message = "setorId é obrigatório")
    private Long setorId;

}
