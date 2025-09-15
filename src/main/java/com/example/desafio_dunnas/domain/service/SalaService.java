package com.example.desafio_dunnas.domain.service;

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

    public Optional<Sala> findById(Long id) {
        return salaRepository.findById(id);
    }

    public void criarSala(String nome, java.math.BigDecimal valorPorHora, Integer capacidadeMaxima, Long setorId) {
        salaRepository.criarSala(nome, valorPorHora, capacidadeMaxima, setorId);
    }

    public void atualizarSala(Long id, String nome, java.math.BigDecimal valorPorHora, Integer capacidadeMaxima, Boolean ativa) {
        salaRepository.atualizarSala(id, nome, valorPorHora, capacidadeMaxima, ativa);
    }

    public Sala save(Sala sala) {
        if (sala.getId() == null) {
            // Criar nova sala usando procedure
            criarSala(sala.getNome(), sala.getValorPorHora(), sala.getCapacidadeMaxima(), sala.getSetor().getId());
            
            // Buscar a sala criada para retornar
            return salaRepository.findByNomeAndSetorId(sala.getNome(), sala.getSetor().getId())
                .orElseThrow(() -> new RuntimeException("Erro ao criar sala"));
        } else {
            // Atualizar sala existente usando procedure
            atualizarSala(sala.getId(), sala.getNome(), sala.getValorPorHora(), sala.getCapacidadeMaxima(), sala.getAtiva());
            
            return salaRepository.findById(sala.getId())
                .orElseThrow(() -> new RuntimeException("Erro ao atualizar sala"));
        }
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

    public Sala update(Long id, Sala salaAtualizada) {
        Optional<Sala> salaOpt = salaRepository.findById(id);
        if (salaOpt.isEmpty()) {
            throw new IllegalArgumentException("Sala não encontrada");
        }

        Sala sala = salaOpt.get();
        sala.setNome(salaAtualizada.getNome());
        sala.setValorPorHora(salaAtualizada.getValorPorHora());
        sala.setCapacidadeMaxima(salaAtualizada.getCapacidadeMaxima());
        sala.setAtiva(salaAtualizada.getAtiva());

        return save(sala);
    }
}
