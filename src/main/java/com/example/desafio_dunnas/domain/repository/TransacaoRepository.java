package com.example.desafio_dunnas.domain.repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.example.desafio_dunnas.domain.entity.Transacao;
import com.example.desafio_dunnas.domain.entity.Transacao.StatusTransacao;
import com.example.desafio_dunnas.domain.entity.Transacao.TipoTransacao;

@Repository
public interface TransacaoRepository extends JpaRepository<Transacao, Long> {

       List<Transacao> findByAgendamentoIdOrderByDataTransacaoDesc(Long agendamentoId);

       List<Transacao> findByAgendamentoClienteIdOrderByDataTransacaoDesc(Long clienteId);

       List<Transacao> findByAgendamentoSalaSetorIdOrderByDataTransacaoDesc(Long setorId);

       List<Transacao> findByStatusOrderByDataTransacaoDesc(StatusTransacao status);

       List<Transacao> findByTipoOrderByDataTransacaoDesc(TipoTransacao tipo);

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

       @Transactional
       @Modifying
       @Query(value = "CALL pr_create_transacao(:p_agendamento_id, :p_valor, :p_tipo, :p_descricao, :p_metodo_pagamento)", nativeQuery = true)
       void criarTransacao(
                     @Param("p_agendamento_id") Long agendamentoId,
                     @Param("p_valor") BigDecimal valor,
                     @Param("p_tipo") String tipo,
                     @Param("p_descricao") String descricao,
                     @Param("p_metodo_pagamento") String metodoPagamento);

       @Transactional
       @Modifying
       @Query(value = "CALL pr_confirmar_transacao(:p_transacao_id)", nativeQuery = true)
       void confirmarTransacao(@Param("p_transacao_id") Long transacaoId);

       @Transactional
       @Modifying
       @Query(value = "CALL pr_cancelar_transacao(:p_transacao_id)", nativeQuery = true)
       void cancelarTransacao(@Param("p_transacao_id") Long transacaoId);
}
