package com.example.desafio_dunnas.domain.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.example.desafio_dunnas.domain.entity.HistoricoAgendamento;

@Repository
public interface HistoricoAgendamentoRepository extends JpaRepository<HistoricoAgendamento, Long> {

    @Query("SELECT h FROM HistoricoAgendamento h WHERE h.agendamento.cliente.id = :clienteId ORDER BY h.dataMudanca DESC")
    List<HistoricoAgendamento> findByCliente(@Param("clienteId") Long clienteId);

    @Query("SELECT h FROM HistoricoAgendamento h WHERE h.agendamento.sala.setor.id = :setorId ORDER BY h.dataMudanca DESC")
    List<HistoricoAgendamento> findBySetor(@Param("setorId") Long setorId);

    @Query("SELECT h FROM HistoricoAgendamento h WHERE h.dataMudanca >= :inicio AND h.dataMudanca <= :fim ORDER BY h.dataMudanca DESC")
    List<HistoricoAgendamento> findByPeriodo(@Param("inicio") LocalDateTime inicio, @Param("fim") LocalDateTime fim);
}
