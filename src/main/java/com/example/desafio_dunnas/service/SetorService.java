package com.example.desafio_dunnas.service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.desafio_dunnas.model.Setor;
import com.example.desafio_dunnas.repository.SetorRepository;

import lombok.RequiredArgsConstructor;

@Service
@Transactional
@RequiredArgsConstructor
public class SetorService {

    private final SetorRepository setorRepository;

    // Consultas que consideram soft delete
    public List<Setor> findAllNaoExcluidos() {
        return setorRepository.findAllNaoExcluidos();
    }

    public List<Setor> findAllExcluidos() {
        return setorRepository.findAllExcluidos();
    }

    public List<Setor> findSetoresAbertos() {
        return setorRepository.findByAbertoTrue();
    }

    public List<Setor> findSetoresSemRecepcionista() {
        return setorRepository.findSetoresSemRecepcionista();
    }

    public Optional<Setor> findById(Long id) {
        return setorRepository.findById(id);
    }

    public void criarSetor(String nome, BigDecimal caixa, Boolean aberto) {
        if (nome == null || nome.isBlank()) {
            throw new IllegalArgumentException("Nome do setor é obrigatório");
        }
        if (caixa == null || caixa.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Caixa deve ser um valor positivo");
        }

        setorRepository.criarSetor(nome, caixa, aberto);
    }

    public void updateSetor(Long id, String nome, BigDecimal caixa, Boolean aberto) {
        if (nome == null || nome.isBlank()) {
            throw new IllegalArgumentException("Nome do setor é obrigatório");
        }
        if (caixa == null || caixa.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Caixa deve ser um valor positivo");
        }

        setorRepository.atualizarSetor(id, nome, caixa, aberto);
    }

    public void abrirSetor(Long setorId) {
        setorRepository.abrirSetor(setorId);
    }

    public void fecharSetor(Long setorId) {
        setorRepository.fecharSetor(setorId);
    }

    public void softDeleteSetor(Long id, Long deletedBy) {
        if (id == null)
            throw new IllegalArgumentException("id é obrigatório");
        if (deletedBy == null)
            throw new IllegalArgumentException("deletedBy é obrigatório");

        setorRepository.softDeleteSetor(id, deletedBy);
    }

    public void reativarSetor(Long id, Long reativadoBy) {
        if (id == null)
            throw new IllegalArgumentException("id é obrigatório");
        if (reativadoBy == null)
            throw new IllegalArgumentException("reativadoBy é obrigatório");

        setorRepository.reativarSetor(id, reativadoBy);
    }
}
