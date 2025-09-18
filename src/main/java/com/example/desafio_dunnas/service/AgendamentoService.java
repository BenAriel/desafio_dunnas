package com.example.desafio_dunnas.service;

import java.time.LocalDateTime;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.desafio_dunnas.model.Agendamento;
import com.example.desafio_dunnas.model.Agendamento.StatusAgendamento;
import com.example.desafio_dunnas.repository.AgendamentoRepository;

import lombok.RequiredArgsConstructor;

@Service
@Transactional
@RequiredArgsConstructor
public class AgendamentoService {

    private final AgendamentoRepository agendamentoRepository;

    public Page<Agendamento> findByClienteId(Long clienteId, Pageable pageable) {
        return agendamentoRepository.findByClienteIdOrderByDataCriacaoDesc(clienteId, pageable);
    }

    public Page<Agendamento> findBySetorId(Long setorId, Pageable pageable) {
        return agendamentoRepository.findBySalaSetorIdOrderByDataCriacaoDesc(setorId, pageable);
    }

    public Page<Agendamento> findBySetorIdAndStatus(Long setorId, StatusAgendamento status, Pageable pageable) {
        return agendamentoRepository.findBySetorIdAndStatus(setorId, status, pageable);
    }

    public void criarAgendamento(Long salaId, Long clienteId, LocalDateTime dataHoraInicio, LocalDateTime dataHoraFim,
            String observacoes) {
        if (salaId == null)
            throw new IllegalArgumentException("salaId é obrigatório");
        if (clienteId == null)
            throw new IllegalArgumentException("clienteId é obrigatório");
        if (dataHoraInicio == null || dataHoraFim == null)
            throw new IllegalArgumentException("datas de início e fim são obrigatórias");
        if (!dataHoraInicio.isBefore(dataHoraFim))
            throw new IllegalArgumentException("dataHoraInicio deve ser anterior a dataHoraFim");
        if (!dataHoraInicio.isAfter(LocalDateTime.now()))
            throw new IllegalArgumentException("dataHoraInicio deve ser futura");

        List<Agendamento> conflitos = agendamentoRepository.findConflitosAgendamento(salaId, dataHoraInicio,
                dataHoraFim);
        if (conflitos != null && !conflitos.isEmpty()) {
            throw new IllegalStateException("Conflito de horário com outro agendamento");
        }

        agendamentoRepository.criarAgendamento(salaId, clienteId, dataHoraInicio, dataHoraFim, observacoes);
    }

    public void confirmarAgendamento(Long agendamentoId) {
        if (agendamentoId == null)
            throw new IllegalArgumentException("agendamentoId é obrigatório");
        Agendamento a = agendamentoRepository.findById(agendamentoId)
                .orElseThrow(() -> new IllegalArgumentException("Agendamento não encontrado"));
        if (a.getStatus() != StatusAgendamento.SOLICITADO)
            throw new IllegalStateException("Apenas solicitações podem ser confirmadas");
        if (a.getDataHoraInicio() != null && LocalDateTime.now().isAfter(a.getDataHoraInicio()))
            throw new IllegalStateException("Não é possível confirmar após o início do agendamento");

        agendamentoRepository.confirmarAgendamento(agendamentoId);
    }

    public void finalizarAgendamento(Long agendamentoId) {
        if (agendamentoId == null)
            throw new IllegalArgumentException("agendamentoId é obrigatório");
        Agendamento a = agendamentoRepository.findById(agendamentoId)
                .orElseThrow(() -> new IllegalArgumentException("Agendamento não encontrado"));
        if (a.getStatus() != StatusAgendamento.CONFIRMADO)
            throw new IllegalStateException("Apenas agendamentos confirmados podem ser finalizados");
        if (a.getDataHoraInicio() != null && LocalDateTime.now().isBefore(a.getDataHoraInicio()))
            throw new IllegalStateException("Não é possível finalizar antes do horário de início");

        agendamentoRepository.finalizarAgendamento(agendamentoId);
    }

    public void cancelarAgendamento(Long agendamentoId) {
        if (agendamentoId == null)
            throw new IllegalArgumentException("agendamentoId é obrigatório");
        Agendamento a = agendamentoRepository.findById(agendamentoId)
                .orElseThrow(() -> new IllegalArgumentException("Agendamento não encontrado"));
        // Regra:
        // - SOLICITADO pode ser cancelado a qualquer momento (mesmo após o início)
        // - CONFIRMADO só pode ser cancelado até o horário de início
        // - Demais status não podem ser cancelados
        if (a.getStatus() == StatusAgendamento.SOLICITADO) {
            // permitido sempre
        } else if (a.getStatus() == StatusAgendamento.CONFIRMADO) {
            if (a.getDataHoraInicio() != null && !LocalDateTime.now().isBefore(a.getDataHoraInicio())) {
                throw new IllegalStateException(
                        "Não é possível cancelar agendamento confirmado após o horário de início");
            }
        } else {
            throw new IllegalStateException("Somente solicitações ou confirmados podem ser cancelados");
        }

        agendamentoRepository.cancelarAgendamento(agendamentoId);
    }

    public List<Agendamento> findConflitosAgendamento(Long salaId, LocalDateTime dataInicio, LocalDateTime dataFim) {
        return agendamentoRepository.findConflitosAgendamento(salaId, dataInicio, dataFim);
    }

    public List<Agendamento> findConfirmadosPorSalaComFimNoFuturo(Long salaId) {
        return agendamentoRepository.findConfirmadosPorSalaComFimNoFuturo(salaId, LocalDateTime.now());
    }
}
