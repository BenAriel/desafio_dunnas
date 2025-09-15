package com.example.desafio_dunnas.domain.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.desafio_dunnas.domain.entity.Transacao;
import com.example.desafio_dunnas.domain.entity.Transacao.StatusTransacao;
import com.example.desafio_dunnas.domain.entity.Transacao.TipoTransacao;
import com.example.desafio_dunnas.domain.repository.TransacaoRepository;

import lombok.RequiredArgsConstructor;

@Service
@Transactional
@RequiredArgsConstructor
public class TransacaoService {

    private final TransacaoRepository transacaoRepository;

    public List<Transacao> findAll() {
        return transacaoRepository.findAll();
    }

    public List<Transacao> findByAgendamentoId(Long agendamentoId) {
        return transacaoRepository.findByAgendamentoIdOrderByDataTransacaoDesc(agendamentoId);
    }

    public List<Transacao> findByClienteId(Long clienteId) {
        return transacaoRepository.findByAgendamentoClienteIdOrderByDataTransacaoDesc(clienteId);
    }

    public List<Transacao> findBySetorId(Long setorId) {
        return transacaoRepository.findByAgendamentoSalaSetorIdOrderByDataTransacaoDesc(setorId);
    }

    public List<Transacao> findByStatus(StatusTransacao status) {
        return transacaoRepository.findByStatusOrderByDataTransacaoDesc(status);
    }

    public List<Transacao> findByTipo(TipoTransacao tipo) {
        return transacaoRepository.findByTipoOrderByDataTransacaoDesc(tipo);
    }

    public List<Transacao> findTransacoesConfirmadasPorPeriodo(Long setorId, LocalDateTime dataInicio, LocalDateTime dataFim) {
        return transacaoRepository.findTransacoesConfirmadasPorPeriodo(setorId, dataInicio, dataFim);
    }

    public BigDecimal sumValorTransacoesConfirmadasPorPeriodo(Long setorId, LocalDateTime dataInicio, LocalDateTime dataFim) {
        Double valor = transacaoRepository.sumValorTransacoesConfirmadasPorPeriodo(setorId, dataInicio, dataFim);
        return valor != null ? BigDecimal.valueOf(valor) : BigDecimal.ZERO;
    }

    public Optional<Transacao> findById(Long id) {
        return transacaoRepository.findById(id);
    }

    public void criarTransacao(Long agendamentoId, java.math.BigDecimal valor, String tipo, String descricao, String metodoPagamento) {
        transacaoRepository.criarTransacao(agendamentoId, valor, tipo, descricao, metodoPagamento);
    }

    public Transacao save(Transacao transacao) {
        // Validações básicas
        if (transacao.getAgendamento() == null || transacao.getAgendamento().getId() == null) {
            throw new IllegalArgumentException("Agendamento é obrigatório");
        }
        
        if (transacao.getValor() == null || transacao.getValor().doubleValue() <= 0) {
            throw new IllegalArgumentException("Valor deve ser maior que zero");
        }
        
        if (transacao.getTipo() == null) {
            throw new IllegalArgumentException("Tipo da transação é obrigatório");
        }

        // Usar procedure para criar transação
        criarTransacao(
            transacao.getAgendamento().getId(),
            transacao.getValor(),
            transacao.getTipo().toString(),
            transacao.getDescricao(),
            transacao.getMetodoPagamento()
        );

        // Buscar a transação criada para retornar
        return transacaoRepository.findAll().stream()
            .filter(t -> t.getAgendamento().getId().equals(transacao.getAgendamento().getId()) &&
                        t.getValor().equals(transacao.getValor()) &&
                        t.getTipo().equals(transacao.getTipo()))
            .findFirst()
            .orElseThrow(() -> new RuntimeException("Erro ao criar transação"));
    }

    public void confirmarTransacao(Long transacaoId) {
        transacaoRepository.confirmarTransacao(transacaoId);
    }

    public void cancelarTransacao(Long transacaoId) {
        transacaoRepository.cancelarTransacao(transacaoId);
    }

    public void criarSinal(Long agendamentoId, BigDecimal valor, String metodoPagamento) {
        criarTransacao(agendamentoId, valor, "SINAL", "Pagamento de sinal (50% do valor total)", metodoPagamento);
    }

    public void criarPagamentoFinal(Long agendamentoId, BigDecimal valor, String metodoPagamento) {
        criarTransacao(agendamentoId, valor, "PAGAMENTO_FINAL", "Pagamento do valor restante", metodoPagamento);
    }

    public void criarReembolso(Long agendamentoId, BigDecimal valor, String descricao) {
        criarTransacao(agendamentoId, valor, "REEMBOLSO", descricao != null ? descricao : "Reembolso de cancelamento", null);
    }
}
