package com.example.desafio_dunnas.service;

import java.math.BigDecimal;
import java.util.List;
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
    public List<Sala> findAllNaoExcluidas() {
        return salaRepository.findAllNaoExcluidas();
    }

    public List<Sala> findAllExcluidas() {
        return salaRepository.findAllExcluidas();
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
