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
        agendamentoRepository.criarAgendamento(salaId, clienteId, dataHoraInicio, dataHoraFim, observacoes);
    }

    public void confirmarAgendamento(Long agendamentoId) {
        agendamentoRepository.confirmarAgendamento(agendamentoId);
    }

    public void finalizarAgendamento(Long agendamentoId) {
        agendamentoRepository.finalizarAgendamento(agendamentoId);
    }

    public void cancelarAgendamento(Long agendamentoId) {
        agendamentoRepository.cancelarAgendamento(agendamentoId);
    }

    public List<Agendamento> findConflitosAgendamento(Long salaId, LocalDateTime dataInicio, LocalDateTime dataFim) {
        return agendamentoRepository.findConflitosAgendamento(salaId, dataInicio, dataFim);
    }

    public List<Agendamento> findConfirmadosPorSalaComFimNoFuturo(Long salaId) {
        return agendamentoRepository.findConfirmadosPorSalaComFimNoFuturo(salaId, LocalDateTime.now());
    }
}
