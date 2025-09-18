package com.example.desafio_dunnas.service;

import java.math.BigDecimal;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.desafio_dunnas.model.Sala;
import com.example.desafio_dunnas.repository.SalaRepository;

import lombok.RequiredArgsConstructor;

@Service
@Transactional
@RequiredArgsConstructor
public class SalaService {

    private final SalaRepository salaRepository;

    // Consultas que consideram soft delete
    public Page<Sala> findAllNaoExcluidas(Pageable pageable) {
        return salaRepository.findAllNaoExcluidas(pageable);
    }

    public Page<Sala> findAllNaoExcluidasBySetor(Long setorId, Pageable pageable) {
        if (setorId == null)
            return findAllNaoExcluidas(pageable);
        return salaRepository.findAllNaoExcluidasBySetor(setorId, pageable);
    }

    public Page<Sala> findAllExcluidas(Pageable pageable) {
        return salaRepository.findAllExcluidas(pageable);
    }

    public List<Sala> findSalasAtivasPorSetor(Long setorId) {
        return salaRepository.findSalasAtivasPorSetor(setorId);
    }

    public List<Sala> findSalasAtivasPorSetorAberto(Long setorId) {
        return salaRepository.findSalasAtivasPorSetorAberto(setorId);
    }

    public Page<Sala> findSalasAtivasPorSetorAberto(Long setorId, Pageable pageable) {
        return salaRepository.findSalasAtivasPorSetorAberto(setorId, pageable);
    }

    public List<Sala> findSalasAtivasDeSetoresAbertos() {
        return salaRepository.findSalasAtivasDeSetoresAbertos();
    }

    public Page<Sala> findSalasAtivasDeSetoresAbertos(Pageable pageable) {
        return salaRepository.findSalasAtivasDeSetoresAbertos(pageable);
    }

    public Optional<Sala> findById(Long id) {
        return salaRepository.findById(id);
    }

    public void criarSala(String nome, BigDecimal valorPorHora, Integer capacidadeMaxima, Long setorId) {
        if (nome == null || nome.isBlank())
            throw new IllegalArgumentException("nome é obrigatório");
        if (valorPorHora == null || valorPorHora.compareTo(BigDecimal.ZERO) <= 0)
            throw new IllegalArgumentException("valorPorHora deve ser maior que zero");
        if (capacidadeMaxima == null || capacidadeMaxima <= 0)
            throw new IllegalArgumentException("capacidadeMaxima deve ser maior que zero");
        if (setorId == null)
            throw new IllegalArgumentException("setorId é obrigatório");

        salaRepository.criarSala(nome, valorPorHora, capacidadeMaxima, setorId);
    }

    public void atualizarSala(Long id, String nome, BigDecimal valorPorHora, Integer capacidadeMaxima, Boolean ativa) {
        if (id == null)
            throw new IllegalArgumentException("id é obrigatório");
        if (nome == null || nome.isBlank())
            throw new IllegalArgumentException("nome é obrigatório");
        if (valorPorHora == null || valorPorHora.compareTo(BigDecimal.ZERO) <= 0)
            throw new IllegalArgumentException("valorPorHora deve ser maior que zero");
        if (capacidadeMaxima == null || capacidadeMaxima <= 0)
            throw new IllegalArgumentException("capacidadeMaxima deve ser maior que zero");

        salaRepository.atualizarSala(id, nome, valorPorHora, capacidadeMaxima, ativa);
    }

    public void softDeleteSala(Long id, Long deletedBy) {
        if (id == null)
            throw new IllegalArgumentException("id é obrigatório");
        if (deletedBy == null)
            throw new IllegalArgumentException("deletedBy é obrigatório");

        salaRepository.softDeleteSala(id, deletedBy);
    }

}
