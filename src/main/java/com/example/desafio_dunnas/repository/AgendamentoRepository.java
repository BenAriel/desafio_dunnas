package com.example.desafio_dunnas.repository;

import java.time.LocalDateTime;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.example.desafio_dunnas.model.Agendamento;
import com.example.desafio_dunnas.model.Agendamento.StatusAgendamento;

@Repository
public interface AgendamentoRepository extends JpaRepository<Agendamento, Long> {

       Page<Agendamento> findByClienteIdOrderByDataCriacaoDesc(Long clienteId, Pageable pageable);

       Page<Agendamento> findBySalaSetorIdOrderByDataCriacaoDesc(Long setorId, Pageable pageable);

       Page<Agendamento> findByStatusOrderByDataCriacaoDesc(StatusAgendamento status, Pageable pageable);

       @Query("SELECT a FROM Agendamento a WHERE a.sala.setor.id = :setorId AND a.status = :status ORDER BY a.dataCriacao DESC")
       Page<Agendamento> findBySetorIdAndStatus(@Param("setorId") Long setorId,
                     @Param("status") StatusAgendamento status, Pageable pageable);

       @Query("SELECT a FROM Agendamento a WHERE a.sala.id = :salaId AND a.status IN ('CONFIRMADO', 'FINALIZADO') " +
                     "AND ((a.dataHoraInicio <= :dataFim AND a.dataHoraFim >= :dataInicio))")
       List<Agendamento> findConflitosAgendamento(@Param("salaId") Long salaId,
                     @Param("dataInicio") LocalDateTime dataInicio,
                     @Param("dataFim") LocalDateTime dataFim);

       @Query("SELECT a FROM Agendamento a WHERE a.sala.id = :salaId AND a.status IN ('CONFIRMADO', 'FINALIZADO') " +
                     "AND a.id != :agendamentoId " +
                     "AND ((a.dataHoraInicio <= :dataFim AND a.dataHoraFim >= :dataInicio))")
       List<Agendamento> findConflitosAgendamentoExcluindo(@Param("salaId") Long salaId,
                     @Param("dataInicio") LocalDateTime dataInicio,
                     @Param("dataFim") LocalDateTime dataFim,
                     @Param("agendamentoId") Long agendamentoId);

       @Query("SELECT a FROM Agendamento a WHERE a.sala.setor.id = :setorId " +
                     "AND a.dataHoraInicio >= :dataInicio AND a.dataHoraInicio <= :dataFim " +
                     "ORDER BY a.dataHoraInicio DESC")
       Page<Agendamento> findAgendamentosPorPeriodo(@Param("setorId") Long setorId,
                     @Param("dataInicio") LocalDateTime dataInicio,
                     @Param("dataFim") LocalDateTime dataFim,
                     Pageable pageable);

       @Query("SELECT a FROM Agendamento a WHERE a.dataHoraInicio >= :dataInicio AND a.dataHoraInicio <= :dataFim " +
                     "ORDER BY a.dataHoraInicio DESC")
       Page<Agendamento> findAgendamentosPorPeriodoGlobal(@Param("dataInicio") LocalDateTime dataInicio,
                     @Param("dataFim") LocalDateTime dataFim,
                     Pageable pageable);


       @Query("SELECT a FROM Agendamento a WHERE a.sala.id = :salaId AND a.status = 'CONFIRMADO' " +
                     "AND a.dataHoraFim >= :agora ORDER BY a.dataHoraInicio")
       List<Agendamento> findConfirmadosPorSalaComFimNoFuturo(@Param("salaId") Long salaId,
                     @Param("agora") LocalDateTime agora);

       @Transactional
       @Modifying
       @Query(value = "CALL pr_create_agendamento(:p_sala_id, :p_cliente_id, :p_data_hora_inicio, :p_data_hora_fim, :p_observacoes)", nativeQuery = true)
       void criarAgendamento(
                     @Param("p_sala_id") Long salaId,
                     @Param("p_cliente_id") Long clienteId,
                     @Param("p_data_hora_inicio") LocalDateTime dataHoraInicio,
                     @Param("p_data_hora_fim") LocalDateTime dataHoraFim,
                     @Param("p_observacoes") String observacoes);

       @Transactional
       @Modifying
       @Query(value = "CALL pr_confirmar_agendamento(:p_agendamento_id)", nativeQuery = true)
       void confirmarAgendamento(@Param("p_agendamento_id") Long agendamentoId);

       @Transactional
       @Modifying
       @Query(value = "CALL pr_finalizar_agendamento(:p_agendamento_id)", nativeQuery = true)
       void finalizarAgendamento(@Param("p_agendamento_id") Long agendamentoId);

       @Transactional
       @Modifying
       @Query(value = "CALL pr_cancelar_agendamento(:p_agendamento_id)", nativeQuery = true)
       void cancelarAgendamento(@Param("p_agendamento_id") Long agendamentoId);
}
