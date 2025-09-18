package com.example.desafio_dunnas.dto.relatorio;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.domain.Page;

import com.example.desafio_dunnas.model.Agendamento;
import com.example.desafio_dunnas.model.HistoricoAgendamento;
import com.example.desafio_dunnas.model.Transacao;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class RelatorioAdminResultDTO {
    private List<Agendamento> agendamentos;
    private Page<Agendamento> agPage;
    private List<Transacao> transacoes;
    private Page<Transacao> txPage;
    private List<HistoricoAgendamento> historicos;
    private Page<HistoricoAgendamento> histPage;
    private BigDecimal valorCaixa;
    private String dataInicioStr;
    private String dataFimStr;
    private LocalDateTime inicio;
    private LocalDateTime fim;
}
