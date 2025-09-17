package com.example.desafio_dunnas.repository;

import java.time.LocalDateTime;
import java.util.List;

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
       List<Transacao> findTransacoesConfirmadasPorPeriodo(@Param("setorId") Long setorId,
                     @Param("dataInicio") LocalDateTime dataInicio,
                     @Param("dataFim") LocalDateTime dataFim);

       @Query("SELECT SUM(t.valor) FROM Transacao t WHERE t.agendamento.sala.setor.id = :setorId " +
                     "AND t.dataTransacao >= :dataInicio AND t.dataTransacao <= :dataFim " +
                     "AND t.status = 'CONFIRMADA'")
       Double sumValorTransacoesConfirmadasPorPeriodo(@Param("setorId") Long setorId,
                     @Param("dataInicio") LocalDateTime dataInicio,
                     @Param("dataFim") LocalDateTime dataFim);

       @Query("SELECT t FROM Transacao t WHERE t.dataTransacao >= :dataInicio AND t.dataTransacao <= :dataFim " +
                     "AND t.status = 'CONFIRMADA' ORDER BY t.dataTransacao DESC")
       List<Transacao> findTransacoesConfirmadasPorPeriodoGlobal(
                     @Param("dataInicio") LocalDateTime dataInicio,
                     @Param("dataFim") LocalDateTime dataFim);

       @Query("SELECT SUM(t.valor) FROM Transacao t WHERE t.dataTransacao >= :dataInicio AND t.dataTransacao <= :dataFim "
                     +
                     "AND t.status = 'CONFIRMADA'")
       Double sumValorTransacoesConfirmadasPorPeriodoGlobal(
                     @Param("dataInicio") LocalDateTime dataInicio,
                     @Param("dataFim") LocalDateTime dataFim);
}
