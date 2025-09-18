package com.example.desafio_dunnas.service;

import java.math.BigDecimal;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
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
    public Page<Setor> findAllNaoExcluidos(Pageable pageable) {
        return setorRepository.findAllNaoExcluidos(pageable);
    }

    // sobrecarga sem paginação par select em formulários
    public List<Setor> findAllNaoExcluidos() {
        return setorRepository.findAllNaoExcluidos(Pageable.unpaged()).getContent();
    }

    public Page<Setor> findAllExcluidos(Pageable pageable) {
        return setorRepository.findAllExcluidos(pageable);
    }

    public List<Setor> findSetoresAbertos() {
        return setorRepository.findByAbertoTrue();
    }

    public Page<Setor> findSetoresAbertos(Pageable pageable) {
        return setorRepository.findByAbertoTrue(pageable);
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

        Setor atual = setorRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Setor não encontrado"));

        setorRepository.atualizarSetor(id, nome, caixa, null);

        // Se o parâmetro 'aberto' foi informado e difere do estado atual, delega às
        // procedures
        if (aberto != null) {
            boolean estavaAberto = Boolean.TRUE.equals(atual.getAberto());
            if (aberto && !estavaAberto) {
                setorRepository.abrirSetor(id);
            } else if (!aberto && estavaAberto) {
                setorRepository.fecharSetor(id);
            }
        }
    }

    public void abrirSetor(Long setorId) {
        if (setorId == null)
            throw new IllegalArgumentException("setorId é obrigatório");
        setorRepository.abrirSetor(setorId);
    }

    public void fecharSetor(Long setorId) {
        if (setorId == null)
            throw new IllegalArgumentException("setorId é obrigatório");
        setorRepository.fecharSetor(setorId);
    }

    public void softDeleteSetor(Long id, Long deletedBy) {
        if (id == null)
            throw new IllegalArgumentException("id é obrigatório");
        if (deletedBy == null)
            throw new IllegalArgumentException("deletedBy é obrigatório");

        // Executa o soft delete do setor; a procedure também soft-deleta salas do setor
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
