package com.example.desafio_dunnas.service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

import org.springframework.stereotype.Service;

import com.example.desafio_dunnas.dto.relatorio.RelatorioAdminResultDTO;
import com.example.desafio_dunnas.dto.relatorio.RelatorioFiltroDTO;
import com.example.desafio_dunnas.dto.relatorio.RelatorioRecepResultDTO;
import com.example.desafio_dunnas.model.Agendamento;
import com.example.desafio_dunnas.model.Agendamento.StatusAgendamento;
import com.example.desafio_dunnas.model.HistoricoAgendamento;
import com.example.desafio_dunnas.model.Setor;
import com.example.desafio_dunnas.model.Transacao;
import com.example.desafio_dunnas.repository.AgendamentoRepository;
import com.example.desafio_dunnas.repository.HistoricoAgendamentoRepository;
import com.example.desafio_dunnas.repository.TransacaoRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class RelatorioService {

    private final AgendamentoRepository agendamentoRepository;
    private final TransacaoRepository transacaoRepository;
    private final HistoricoAgendamentoRepository historicoRepository;
    private final SetorService setorService;

    public Page<Agendamento> agendamentosPorPeriodoSetor(Long setorId, LocalDateTime inicio, LocalDateTime fim,
            Pageable pageable) {
        if (inicio == null || fim == null)
            return Page.empty(pageable);
        if (setorId == null) {
            return agendamentoRepository.findAgendamentosPorPeriodoGlobal(inicio, fim, pageable);
        }
        return agendamentoRepository.findAgendamentosPorPeriodo(setorId, inicio, fim, pageable);
    }

    public Page<Transacao> transacoesConfirmadasPorPeriodoSetor(Long setorId, LocalDateTime inicio, LocalDateTime fim,
            Pageable pageable) {
        if (inicio == null || fim == null)
            return Page.empty(pageable);
        if (setorId == null) {
            return transacaoRepository.findTransacoesConfirmadasPorPeriodoGlobal(inicio, fim, pageable);
        }
        return transacaoRepository.findTransacoesConfirmadasPorPeriodo(setorId, inicio, fim, pageable);
    }

    public BigDecimal valorTransacoesConfirmadasPorPeriodoSetor(Long setorId, LocalDateTime inicio, LocalDateTime fim) {
        if (inicio == null || fim == null)
            return BigDecimal.ZERO;
        Double valor = (setorId == null)
                ? transacaoRepository.sumValorTransacoesConfirmadasPorPeriodoGlobal(inicio, fim)
                : transacaoRepository.sumValorTransacoesConfirmadasPorPeriodo(setorId, inicio, fim);
        return valor != null ? BigDecimal.valueOf(valor) : BigDecimal.ZERO;
    }

    // Versões paginadas dos históricos
    public Page<HistoricoAgendamento> pageHistoricoPorCliente(Long clienteId, Pageable pageable) {
        if (clienteId == null)
            return Page.empty(pageable);
        return historicoRepository.findPageByCliente(clienteId, pageable);
    }

    public Page<HistoricoAgendamento> pageHistoricoPorSetor(Long setorId, Pageable pageable) {
        if (setorId == null)
            return Page.empty(pageable);
        return historicoRepository.findPageBySetor(setorId, pageable);
    }

    public Page<HistoricoAgendamento> pageHistoricoPorPeriodo(LocalDateTime inicio, LocalDateTime fim,
            Pageable pageable) {
        if (inicio == null || fim == null)
            return Page.empty(pageable);
        return historicoRepository.findPageByPeriodo(inicio, fim, pageable);
    }

    public RelatorioRecepResultDTO gerarRelatorioRecep(RelatorioFiltroDTO filtro) {
        LocalDate ini = (filtro.getDataInicio() != null && !filtro.getDataInicio().isBlank())
                ? LocalDate.parse(filtro.getDataInicio())
                : LocalDate.now().minusDays(30);
        LocalDate fimD = (filtro.getDataFim() != null && !filtro.getDataFim().isBlank())
                ? LocalDate.parse(filtro.getDataFim())
                : LocalDate.now();
        LocalDateTime inicio = ini.atStartOfDay();
        LocalDateTime fim = fimD.atTime(23, 59, 59);

        int agPage = Math.max(filtro.getAgPage(), 0);
        int agSize = Math.max(filtro.getAgSize(), 1);
        int histPageIdx = Math.max(filtro.getHistPage(), 0);
        int histSize = Math.max(filtro.getHistSize(), 1);
        int txPageIdx = Math.max(filtro.getTxPage(), 0);
        int txSize = Math.max(filtro.getTxSize(), 1);

        Pageable agPageable = PageRequest.of(agPage, agSize);
        Pageable histPageable = PageRequest.of(histPageIdx, histSize);
        Pageable txPageable = PageRequest.of(txPageIdx, txSize);

        Page<Agendamento> agendamentosPeriodo = agendamentosPorPeriodoSetor(filtro.getSetorId(),
                inicio, fim, agPageable);

        if (filtro.getStatus() != null && !filtro.getStatus().isBlank()
                && !"TODOS".equalsIgnoreCase(filtro.getStatus())) {
            try {
                StatusAgendamento st = StatusAgendamento.valueOf(filtro.getStatus().toUpperCase());
                agendamentosPeriodo = new PageImpl<>(
                        agendamentosPeriodo.getContent().stream().filter(a -> a.getStatus() == st).toList(),
                        agPageable,
                        agendamentosPeriodo.getTotalElements());
            } catch (IllegalArgumentException ignore) {
            }
        }
        if (filtro.getClienteId() != null) {
            Long cid = filtro.getClienteId();
            agendamentosPeriodo = new PageImpl<>(
                    agendamentosPeriodo.getContent().stream()
                            .filter(a -> a.getCliente() != null && a.getCliente().getId().equals(cid))
                            .toList(),
                    agPageable,
                    agendamentosPeriodo.getTotalElements());
        }

        Page<HistoricoAgendamento> histPage = pageHistoricoPorSetor(filtro.getSetorId(), histPageable);
        List<HistoricoAgendamento> historicosFiltrados = histPage.getContent().stream()
                .filter(h -> !h.getDataMudanca().isBefore(inicio) && !h.getDataMudanca().isAfter(fim))
                .toList();
        histPage = new PageImpl<>(historicosFiltrados, histPageable, histPage.getTotalElements());

        var transacoes = transacoesConfirmadasPorPeriodoSetor(filtro.getSetorId(), inicio, fim,
                txPageable);

        return RelatorioRecepResultDTO.builder()
                .agendamentos(agendamentosPeriodo.getContent())
                .agPage(agendamentosPeriodo)
                .historicos(histPage.getContent())
                .histPage(histPage)
                .transacoes(transacoes.getContent())
                .txPage(transacoes)
                .dataInicioStr(ini.toString())
                .dataFimStr(fimD.toString())
                .inicio(inicio)
                .fim(fim)
                .build();
    }

    public RelatorioAdminResultDTO gerarRelatorio(RelatorioFiltroDTO filtro) {
        LocalDate ini = (filtro.getDataInicio() != null && !filtro.getDataInicio().isBlank())
                ? LocalDate.parse(filtro.getDataInicio())
                : LocalDate.now().minusDays(30);
        LocalDate fimD = (filtro.getDataFim() != null && !filtro.getDataFim().isBlank())
                ? LocalDate.parse(filtro.getDataFim())
                : LocalDate.now();
        LocalDateTime inicio = ini.atStartOfDay();
        LocalDateTime fim = fimD.atTime(23, 59, 59);

        Pageable agPageable = PageRequest.of(Math.max(filtro.getAgPage(), 0), Math.max(filtro.getAgSize(), 1));
        Pageable histPageable = PageRequest.of(Math.max(filtro.getHistPage(), 0), Math.max(filtro.getHistSize(), 1));
        Pageable txPageable = PageRequest.of(Math.max(filtro.getTxPage(), 0), Math.max(filtro.getTxSize(), 1));

        Page<Agendamento> agendamentos = agendamentosPorPeriodoSetor(filtro.getSetorId(), inicio, fim, agPageable);

        // Filtro por status
        if (filtro.getStatus() != null && !filtro.getStatus().isBlank()
                && !"TODOS".equalsIgnoreCase(filtro.getStatus())) {
            try {
                StatusAgendamento st = StatusAgendamento.valueOf(filtro.getStatus().toUpperCase());
                agendamentos = new PageImpl<>(
                        agendamentos.getContent().stream().filter(a -> a.getStatus() == st).toList(),
                        agPageable,
                        agendamentos.getTotalElements());
            } catch (IllegalArgumentException ignore) {
            }
        }

        // Filtro por cliente
        if (filtro.getClienteId() != null) {
            Long cid = filtro.getClienteId();
            agendamentos = new PageImpl<>(
                    agendamentos.getContent().stream()
                            .filter(a -> a.getCliente() != null && a.getCliente().getId().equals(cid)).toList(),
                    agPageable,
                    agendamentos.getTotalElements());
        }

        Page<com.example.desafio_dunnas.model.Transacao> transacoes = transacoesConfirmadasPorPeriodoSetor(
                filtro.getSetorId(), inicio, fim, txPageable);

        // Filtro por status em transações (status do agendamento)
        if (filtro.getStatus() != null && !filtro.getStatus().isBlank()
                && !"TODOS".equalsIgnoreCase(filtro.getStatus())) {
            try {
                StatusAgendamento st = StatusAgendamento.valueOf(filtro.getStatus().toUpperCase());
                transacoes = new PageImpl<>(
                        transacoes.getContent().stream()
                                .filter(t -> t.getAgendamento() != null && t.getAgendamento().getStatus() == st)
                                .toList(),
                        txPageable,
                        transacoes.getTotalElements());
            } catch (IllegalArgumentException ignore) {
            }
        }

        // Filtro por cliente em transações
        if (filtro.getClienteId() != null) {
            Long cid = filtro.getClienteId();
            transacoes = new PageImpl<>(
                    transacoes.getContent().stream()
                            .filter(t -> t.getAgendamento() != null && t.getAgendamento().getCliente() != null
                                    && t.getAgendamento().getCliente().getId().equals(cid))
                            .toList(),
                    txPageable,
                    transacoes.getTotalElements());
        }

        // Valor em caixa
        BigDecimal valorCaixa;
        if (filtro.getSetorId() != null) {
            valorCaixa = setorService.findById(filtro.getSetorId()).map(Setor::getCaixa).orElse(BigDecimal.ZERO);
        } else {
            // Somatório do caixa de todos os setores não excluídos
            valorCaixa = setorService.findAllNaoExcluidos().stream()
                    .map(s -> s.getCaixa() != null ? s.getCaixa() : BigDecimal.ZERO)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
        }

        // Histórico
        Page<HistoricoAgendamento> histPage;
        if (filtro.getSetorId() != null) {
            histPage = pageHistoricoPorSetor(filtro.getSetorId(), histPageable);
            List<HistoricoAgendamento> historicosFiltrados = histPage.getContent().stream()
                    .filter(h -> !h.getDataMudanca().isBefore(inicio) && !h.getDataMudanca().isAfter(fim))
                    .filter(h -> {
                        if (filtro.getStatus() == null || filtro.getStatus().isBlank()
                                || "TODOS".equalsIgnoreCase(filtro.getStatus()))
                            return true;
                        try {
                            StatusAgendamento st = StatusAgendamento.valueOf(filtro.getStatus().toUpperCase());
                            String stName = st.name();
                            return (h.getStatusAnterior() != null && h.getStatusAnterior().equalsIgnoreCase(stName))
                                    || (h.getStatusNovo() != null && h.getStatusNovo().equalsIgnoreCase(stName));
                        } catch (IllegalArgumentException e) {
                            return true;
                        }
                    })
                    .filter(h -> filtro.getClienteId() == null || (h.getAgendamento() != null
                            && h.getAgendamento().getCliente() != null
                            && h.getAgendamento().getCliente().getId().equals(filtro.getClienteId())))
                    .toList();
            histPage = new PageImpl<>(historicosFiltrados, histPageable, histPage.getTotalElements());
        } else {
            histPage = pageHistoricoPorPeriodo(inicio, fim, histPageable);
            List<HistoricoAgendamento> historicosFiltrados = histPage.getContent().stream()
                    .filter(h -> {
                        if (filtro.getStatus() == null || filtro.getStatus().isBlank()
                                || "TODOS".equalsIgnoreCase(filtro.getStatus()))
                            return true;
                        try {
                            StatusAgendamento st = StatusAgendamento.valueOf(filtro.getStatus().toUpperCase());
                            String stName = st.name();
                            return (h.getStatusAnterior() != null && h.getStatusAnterior().equalsIgnoreCase(stName))
                                    || (h.getStatusNovo() != null && h.getStatusNovo().equalsIgnoreCase(stName));
                        } catch (IllegalArgumentException e) {
                            return true;
                        }
                    })
                    .filter(h -> filtro.getClienteId() == null || (h.getAgendamento() != null
                            && h.getAgendamento().getCliente() != null
                            && h.getAgendamento().getCliente().getId().equals(filtro.getClienteId())))
                    .toList();
            histPage = new PageImpl<>(historicosFiltrados, histPageable, histPage.getTotalElements());
        }

        return RelatorioAdminResultDTO.builder()
                .agendamentos(agendamentos.getContent())
                .agPage(agendamentos)
                .transacoes(transacoes.getContent())
                .txPage(transacoes)
                .historicos(histPage.getContent())
                .histPage(histPage)
                .valorCaixa(valorCaixa)
                .dataInicioStr(ini.toString())
                .dataFimStr(fimD.toString())
                .inicio(inicio)
                .fim(fim)
                .build();
    }
}
