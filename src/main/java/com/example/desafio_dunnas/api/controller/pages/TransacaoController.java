package com.example.desafio_dunnas.api.controller.pages;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.example.desafio_dunnas.domain.entity.Transacao;
import com.example.desafio_dunnas.domain.service.AgendamentoService;
import com.example.desafio_dunnas.domain.service.TransacaoService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/transacoes")
@RequiredArgsConstructor
public class TransacaoController {

    private final TransacaoService transacaoService;
    private final AgendamentoService agendamentoService;

    @GetMapping({ "", "/" })
    public String listarTransacoes(Model model) {
        List<Transacao> transacoes = transacaoService.findAll();
        model.addAttribute("transacoes", transacoes);
        return "transacoes/lista";
    }

    @GetMapping("/por-agendamento")
    public String listarPorAgendamento(@RequestParam Long agendamentoId, Model model) {
        List<Transacao> transacoes = transacaoService.findByAgendamentoId(agendamentoId);
        model.addAttribute("transacoes", transacoes);
        model.addAttribute("agendamentoId", agendamentoId);
        return "transacoes/lista";
    }

    @GetMapping("/por-cliente")
    public String listarPorCliente(@RequestParam Long clienteId, Model model) {
        List<Transacao> transacoes = transacaoService.findByClienteId(clienteId);
        model.addAttribute("transacoes", transacoes);
        model.addAttribute("clienteId", clienteId);
        return "transacoes/lista";
    }

    @GetMapping("/por-setor")
    public String listarPorSetor(@RequestParam Long setorId, Model model) {
        List<Transacao> transacoes = transacaoService.findBySetorId(setorId);
        model.addAttribute("transacoes", transacoes);
        model.addAttribute("setorId", setorId);
        return "transacoes/lista";
    }

    @GetMapping("/pagar-sinal")
    public String pagarSinalForm(@RequestParam Long agendamentoId, Model model) {
        var agendamento = agendamentoService.findById(agendamentoId)
            .orElseThrow(() -> new IllegalArgumentException("Agendamento não encontrado"));
        
        model.addAttribute("agendamento", agendamento);
        return "transacoes/pagar-sinal";
    }

    @PostMapping("/pagar-sinal")
    public String pagarSinal(
            @RequestParam Long agendamentoId,
            @RequestParam BigDecimal valor,
            @RequestParam String metodoPagamento) {
        
        try {
            transacaoService.criarSinal(agendamentoId, valor, metodoPagamento);
            return "redirect:/transacoes/por-agendamento?agendamentoId=" + agendamentoId + "&success=Sinal pago com sucesso";
        } catch (Exception e) {
            return "redirect:/transacoes/pagar-sinal?agendamentoId=" + agendamentoId + "&error=" + e.getMessage();
        }
    }

    @GetMapping("/pagar-final")
    public String pagarFinalForm(@RequestParam Long agendamentoId, Model model) {
        var agendamento = agendamentoService.findById(agendamentoId)
            .orElseThrow(() -> new IllegalArgumentException("Agendamento não encontrado"));
        
        model.addAttribute("agendamento", agendamento);
        return "transacoes/pagar-final";
    }

    @PostMapping("/pagar-final")
    public String pagarFinal(
            @RequestParam Long agendamentoId,
            @RequestParam BigDecimal valor,
            @RequestParam String metodoPagamento) {
        
        try {
            transacaoService.criarPagamentoFinal(agendamentoId, valor, metodoPagamento);
            return "redirect:/transacoes/por-agendamento?agendamentoId=" + agendamentoId + "&success=Pagamento final realizado com sucesso";
        } catch (Exception e) {
            return "redirect:/transacoes/pagar-final?agendamentoId=" + agendamentoId + "&error=" + e.getMessage();
        }
    }

    @PostMapping("/confirmar")
    public String confirmar(@RequestParam Long transacaoId) {
        try {
            transacaoService.confirmarTransacao(transacaoId);
            return "redirect:/transacoes?success=Transação confirmada com sucesso";
        } catch (Exception e) {
            return "redirect:/transacoes?error=" + e.getMessage();
        }
    }

    @PostMapping("/cancelar")
    public String cancelar(@RequestParam Long transacaoId) {
        try {
            transacaoService.cancelarTransacao(transacaoId);
            return "redirect:/transacoes?success=Transação cancelada com sucesso";
        } catch (Exception e) {
            return "redirect:/transacoes?error=" + e.getMessage();
        }
    }

    @GetMapping("/relatorio-setor")
    public String relatorioSetor(
            @RequestParam Long setorId,
            @RequestParam(required = false) String dataInicio,
            @RequestParam(required = false) String dataFim,
            Model model) {
        
        try {
            LocalDateTime inicio = dataInicio != null ? LocalDateTime.parse(dataInicio + "T00:00:00") : LocalDateTime.now().minusMonths(1);
            LocalDateTime fim = dataFim != null ? LocalDateTime.parse(dataFim + "T23:59:59") : LocalDateTime.now();
            
            List<Transacao> transacoes = transacaoService.findTransacoesConfirmadasPorPeriodo(setorId, inicio, fim);
            BigDecimal valorTotal = transacaoService.sumValorTransacoesConfirmadasPorPeriodo(setorId, inicio, fim);
            
            model.addAttribute("transacoes", transacoes);
            model.addAttribute("valorTotal", valorTotal);
            model.addAttribute("setorId", setorId);
            model.addAttribute("dataInicio", dataInicio);
            model.addAttribute("dataFim", dataFim);
            
            return "transacoes/relatorio-setor";
        } catch (Exception e) {
            return "redirect:/transacoes/por-setor?setorId=" + setorId + "&error=" + e.getMessage();
        }
    }

    @GetMapping("/reembolso")
    public String reembolsoForm(@RequestParam Long agendamentoId, Model model) {
        var agendamento = agendamentoService.findById(agendamentoId)
            .orElseThrow(() -> new IllegalArgumentException("Agendamento não encontrado"));
        
        model.addAttribute("agendamento", agendamento);
        return "transacoes/reembolso";
    }

    @PostMapping("/reembolso")
    public String reembolso(
            @RequestParam Long agendamentoId,
            @RequestParam BigDecimal valor,
            @RequestParam String descricao) {
        
        try {
            transacaoService.criarReembolso(agendamentoId, valor, descricao);
            return "redirect:/transacoes/por-agendamento?agendamentoId=" + agendamentoId + "&success=Reembolso criado com sucesso";
        } catch (Exception e) {
            return "redirect:/transacoes/reembolso?agendamentoId=" + agendamentoId + "&error=" + e.getMessage();
        }
    }
}
