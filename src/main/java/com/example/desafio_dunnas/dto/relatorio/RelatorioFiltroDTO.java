package com.example.desafio_dunnas.dto.relatorio;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class RelatorioFiltroDTO {
    private Long setorId;
    private String dataInicio;
    private String dataFim;
    private String status;
    private Long clienteId;
    private int agPage;
    private int agSize;
    private int histPage;
    private int histSize;
    private int txPage;
    private int txSize;
}
