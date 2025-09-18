package com.example.desafio_dunnas.repository;

import java.time.LocalDateTime;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.example.desafio_dunnas.model.HistoricoAgendamento;

@Repository
public interface HistoricoAgendamentoRepository extends JpaRepository<HistoricoAgendamento, Long> {

    // Versões paginadas
    @Query("SELECT h FROM HistoricoAgendamento h WHERE h.agendamento.cliente.id = :clienteId ORDER BY h.dataMudanca DESC")
    Page<HistoricoAgendamento> findPageByCliente(@Param("clienteId") Long clienteId, Pageable pageable);

    @Query("SELECT h FROM HistoricoAgendamento h WHERE h.agendamento.sala.setor.id = :setorId ORDER BY h.dataMudanca DESC")
    Page<HistoricoAgendamento> findPageBySetor(@Param("setorId") Long setorId, Pageable pageable);

    @Query("SELECT h FROM HistoricoAgendamento h WHERE h.dataMudanca >= :inicio AND h.dataMudanca <= :fim ORDER BY h.dataMudanca DESC")
    Page<HistoricoAgendamento> findPageByPeriodo(@Param("inicio") LocalDateTime inicio, @Param("fim") LocalDateTime fim,
            Pageable pageable);
}
