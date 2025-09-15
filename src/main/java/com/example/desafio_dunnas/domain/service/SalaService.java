package com.example.desafio_dunnas.domain.service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.desafio_dunnas.domain.entity.Sala;
import com.example.desafio_dunnas.domain.repository.SalaRepository;

import lombok.RequiredArgsConstructor;

@Service
@Transactional
@RequiredArgsConstructor
public class SalaService {

    private final SalaRepository salaRepository;

    public List<Sala> findAll() {
        return salaRepository.findAll();
    }

    public List<Sala> findSalasAtivas() {
        return salaRepository.findByAtivaTrue();
    }

    public List<Sala> findSalasAtivasPorSetor(Long setorId) {
        return salaRepository.findSalasAtivasPorSetor(setorId);
    }

    public List<Sala> findSalasAtivasPorSetorAberto(Long setorId) {
        return salaRepository.findSalasAtivasPorSetorAberto(setorId);
    }

    public List<Sala> findSalasAtivasDeSetoresAbertos() {
        return salaRepository.findSalasAtivasDeSetoresAbertos();
    }

    public Optional<Sala> findById(Long id) {
        return salaRepository.findById(id);
    }

    public void criarSala(String nome, BigDecimal valorPorHora, Integer capacidadeMaxima, Long setorId, Boolean ativa) {
        salaRepository.criarSala(nome, valorPorHora, capacidadeMaxima, setorId, ativa);
    }

    public void atualizarSala(Long id, String nome, BigDecimal valorPorHora, Integer capacidadeMaxima, Boolean ativa, Long setorId) {
        salaRepository.atualizarSala(id, nome, valorPorHora, capacidadeMaxima, ativa, setorId);
    }

    public void deleteById(Long id) {
        Optional<Sala> salaOpt = salaRepository.findById(id);
        if (salaOpt.isEmpty()) {
            throw new IllegalArgumentException("Sala não encontrada");
        }

        // Em vez de deletar, marca como inativa
        Sala sala = salaOpt.get();
        sala.setAtiva(false);
        salaRepository.save(sala);
    }

}
