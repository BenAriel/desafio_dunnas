package com.example.desafio_dunnas.domain.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;

import org.springframework.stereotype.Service;

import com.example.desafio_dunnas.domain.entity.Agendamento;
import com.example.desafio_dunnas.domain.entity.HistoricoAgendamento;
import com.example.desafio_dunnas.domain.entity.Transacao;
import com.example.desafio_dunnas.domain.repository.AgendamentoRepository;
import com.example.desafio_dunnas.domain.repository.HistoricoAgendamentoRepository;
import com.example.desafio_dunnas.domain.repository.TransacaoRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class RelatorioService {

    private final AgendamentoRepository agendamentoRepository;
    private final TransacaoRepository transacaoRepository;
    private final HistoricoAgendamentoRepository historicoRepository;

    public List<Agendamento> agendamentosPorPeriodoSetor(Long setorId, LocalDateTime inicio, LocalDateTime fim) {
        if (inicio == null || fim == null)
            return Collections.emptyList();
        if (setorId == null) {
            return agendamentoRepository.findAgendamentosPorPeriodoGlobal(inicio, fim);
        }
        return agendamentoRepository.findAgendamentosPorPeriodo(setorId, inicio, fim);
    }

    public List<Transacao> transacoesConfirmadasPorPeriodoSetor(Long setorId, LocalDateTime inicio, LocalDateTime fim) {
        if (inicio == null || fim == null)
            return Collections.emptyList();
        if (setorId == null) {
            return transacaoRepository.findTransacoesConfirmadasPorPeriodoGlobal(inicio, fim);
        }
        return transacaoRepository.findTransacoesConfirmadasPorPeriodo(setorId, inicio, fim);
    }

    public BigDecimal valorTransacoesConfirmadasPorPeriodoSetor(Long setorId, LocalDateTime inicio, LocalDateTime fim) {
        if (inicio == null || fim == null)
            return BigDecimal.ZERO;
        Double valor = (setorId == null)
                ? transacaoRepository.sumValorTransacoesConfirmadasPorPeriodoGlobal(inicio, fim)
                : transacaoRepository.sumValorTransacoesConfirmadasPorPeriodo(setorId, inicio, fim);
        return valor != null ? BigDecimal.valueOf(valor) : BigDecimal.ZERO;
    }

    public List<HistoricoAgendamento> historicoPorCliente(Long clienteId) {
        if (clienteId == null)
            return Collections.emptyList();
        return historicoRepository.findByCliente(clienteId);
    }

    public List<HistoricoAgendamento> historicoPorSetor(Long setorId) {
        if (setorId == null)
            return Collections.emptyList();
        return historicoRepository.findBySetor(setorId);
    }

    public List<HistoricoAgendamento> historicoPorPeriodo(LocalDateTime inicio, LocalDateTime fim) {
        if (inicio == null || fim == null)
            return Collections.emptyList();
        return historicoRepository.findByPeriodo(inicio, fim);
    }
}
