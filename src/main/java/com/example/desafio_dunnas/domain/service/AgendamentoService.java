package com.example.desafio_dunnas.domain.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.desafio_dunnas.domain.entity.Agendamento;
import com.example.desafio_dunnas.domain.entity.Agendamento.StatusAgendamento;
import com.example.desafio_dunnas.domain.repository.AgendamentoRepository;

import lombok.RequiredArgsConstructor;

@Service
@Transactional
@RequiredArgsConstructor
public class AgendamentoService {

    private final AgendamentoRepository agendamentoRepository;

    public List<Agendamento> findAll() {
        return agendamentoRepository.findAll();
    }

    public List<Agendamento> findByClienteId(Long clienteId) {
        return agendamentoRepository.findByClienteIdOrderByDataCriacaoDesc(clienteId);
    }

    public List<Agendamento> findBySetorId(Long setorId) {
        return agendamentoRepository.findBySalaSetorIdOrderByDataCriacaoDesc(setorId);
    }

    public List<Agendamento> findByStatus(StatusAgendamento status) {
        return agendamentoRepository.findByStatusOrderByDataCriacaoDesc(status);
    }

    public List<Agendamento> findBySetorIdAndStatus(Long setorId, StatusAgendamento status) {
        return agendamentoRepository.findBySetorIdAndStatus(setorId, status);
    }

    public Optional<Agendamento> findById(Long id) {
        return agendamentoRepository.findById(id);
    }

    public void criarAgendamento(Long salaId, Long clienteId, LocalDateTime dataHoraInicio, LocalDateTime dataHoraFim, String observacoes) {
        agendamentoRepository.criarAgendamento(salaId, clienteId, dataHoraInicio, dataHoraFim, observacoes);
    }

    public Agendamento save(Agendamento agendamento) {
        // Validações básicas
        if (agendamento.getSala() == null || agendamento.getSala().getId() == null) {
            throw new IllegalArgumentException("Sala é obrigatória");
        }
        
        if (agendamento.getCliente() == null || agendamento.getCliente().getId() == null) {
            throw new IllegalArgumentException("Cliente é obrigatório");
        }
        
        if (agendamento.getDataHoraInicio() == null) {
            throw new IllegalArgumentException("Data/hora de início é obrigatória");
        }
        
        if (agendamento.getDataHoraFim() == null) {
            throw new IllegalArgumentException("Data/hora de fim é obrigatória");
        }

        // Usar procedure para criar agendamento
        criarAgendamento(
            agendamento.getSala().getId(),
            agendamento.getCliente().getId(),
            agendamento.getDataHoraInicio(),
            agendamento.getDataHoraFim(),
            agendamento.getObservacoes()
        );

        // Buscar o agendamento criado para retornar
        return agendamentoRepository.findAll().stream()
            .filter(a -> a.getSala().getId().equals(agendamento.getSala().getId()) &&
                        a.getCliente().getId().equals(agendamento.getCliente().getId()) &&
                        a.getDataHoraInicio().equals(agendamento.getDataHoraInicio()))
            .findFirst()
            .orElseThrow(() -> new RuntimeException("Erro ao criar agendamento"));
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

    public List<Agendamento> findConflitosAgendamentoExcluindo(Long salaId, LocalDateTime dataInicio, LocalDateTime dataFim, Long agendamentoId) {
        return agendamentoRepository.findConflitosAgendamentoExcluindo(salaId, dataInicio, dataFim, agendamentoId);
    }

    public List<Agendamento> findAgendamentosPorPeriodo(Long setorId, LocalDateTime dataInicio, LocalDateTime dataFim) {
        return agendamentoRepository.findAgendamentosPorPeriodo(setorId, dataInicio, dataFim);
    }
}
