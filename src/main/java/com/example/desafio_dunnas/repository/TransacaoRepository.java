package com.example.desafio_dunnas.repository;

import java.time.LocalDateTime;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.example.desafio_dunnas.model.Transacao;

@Repository
public interface TransacaoRepository extends JpaRepository<Transacao, Long> {

       @Query("SELECT t FROM Transacao t WHERE t.agendamento.sala.setor.id = :setorId " +
                     "AND t.dataTransacao >= :dataInicio AND t.dataTransacao <= :dataFim " +
                     "AND t.status = 'CONFIRMADA' ORDER BY t.dataTransacao DESC")
       Page<Transacao> findTransacoesConfirmadasPorPeriodo(@Param("setorId") Long setorId,
                     @Param("dataInicio") LocalDateTime dataInicio,
                     @Param("dataFim") LocalDateTime dataFim,
                     Pageable pageable);

       @Query("SELECT SUM(t.valor) FROM Transacao t WHERE t.agendamento.sala.setor.id = :setorId " +
                     "AND t.dataTransacao >= :dataInicio AND t.dataTransacao <= :dataFim " +
                     "AND t.status = 'CONFIRMADA'")
       Double sumValorTransacoesConfirmadasPorPeriodo(@Param("setorId") Long setorId,
                     @Param("dataInicio") LocalDateTime dataInicio,
                     @Param("dataFim") LocalDateTime dataFim);

       @Query("SELECT t FROM Transacao t WHERE t.dataTransacao >= :dataInicio AND t.dataTransacao <= :dataFim " +
                     "AND t.status = 'CONFIRMADA' ORDER BY t.dataTransacao DESC")
       Page<Transacao> findTransacoesConfirmadasPorPeriodoGlobal(
                     @Param("dataInicio") LocalDateTime dataInicio,
                     @Param("dataFim") LocalDateTime dataFim,
                     Pageable pageable);

       @Query("SELECT SUM(t.valor) FROM Transacao t WHERE t.dataTransacao >= :dataInicio AND t.dataTransacao <= :dataFim "
                     +
                     "AND t.status = 'CONFIRMADA'")
       Double sumValorTransacoesConfirmadasPorPeriodoGlobal(
                     @Param("dataInicio") LocalDateTime dataInicio,
                     @Param("dataFim") LocalDateTime dataFim);
}
