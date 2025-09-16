package com.example.desafio_dunnas.api.controller.pages;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.validation.BindingResult;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import jakarta.validation.Valid;

import com.example.desafio_dunnas.api.dto.agendamento.ClienteSolicitarAgendamentoForm;
import com.example.desafio_dunnas.domain.entity.Agendamento;
import com.example.desafio_dunnas.domain.entity.Cliente;
import com.example.desafio_dunnas.domain.entity.Sala;
import com.example.desafio_dunnas.domain.entity.Setor;
import com.example.desafio_dunnas.domain.service.AgendamentoService;
import com.example.desafio_dunnas.domain.service.ClienteService;
import com.example.desafio_dunnas.domain.service.SalaService;
import com.example.desafio_dunnas.domain.service.SetorService;

import com.example.desafio_dunnas.domain.service.RelatorioService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/cliente")
@RequiredArgsConstructor
public class ClienteController {

    private final AgendamentoService agendamentoService;
    private final SalaService salaService;
    private final SetorService setorService;
    private final ClienteService clienteService;
    private final RelatorioService relatorioService;

    @GetMapping({ "", "/" })
    public String clienteHome() {
        return "cliente/cliente";
    }

    @GetMapping("/setores")
    public String listarSetores(Model model) {
        List<Setor> setores = setorService.findSetoresAbertos();
        model.addAttribute("setores", setores);
        return "cliente/setores";
    }

    @GetMapping("/salas")
    public String listarSalas(@RequestParam(required = false) Long setorId, Model model) {
        List<Sala> salas;
        if (setorId != null) {
            salas = salaService.findSalasAtivasPorSetorAberto(setorId);
            Setor setor = setorService.findById(setorId)
                    .orElseThrow(() -> new IllegalArgumentException("Setor não encontrado"));
            model.addAttribute("setor", setor);
        } else {
            salas = salaService.findSalasAtivasDeSetoresAbertos();
        }

        List<Setor> setores = setorService.findAll();
        model.addAttribute("salas", salas);
        model.addAttribute("setores", setores);
        model.addAttribute("setorId", setorId);

        return "cliente/salas";
    }

    @GetMapping("/agendamentos/solicitar")
    public String solicitarAgendamentoForm(@RequestParam(required = false) Long salaId,
            Model model,
            RedirectAttributes redirectAttributes) {
        if (salaId == null) {
            redirectAttributes.addFlashAttribute("error", "Selecione uma sala para solicitar agendamento.");
            return "redirect:/cliente/salas";
        }
        Sala sala = salaService.findById(salaId)
                .orElseThrow(() -> new IllegalArgumentException("Sala não encontrada"));

        model.addAttribute("sala", sala);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
        model.addAttribute("minDateTime", LocalDateTime.now().plusMinutes(1).format(formatter));
        if (!model.containsAttribute("form")) {
            ClienteSolicitarAgendamentoForm form = new ClienteSolicitarAgendamentoForm();
            form.setSalaId(salaId);
            model.addAttribute("form", form);
        }
        var confirmados = agendamentoService.findConfirmadosPorSalaComFimNoFuturo(salaId);
        model.addAttribute("confirmados", confirmados);
        return "cliente/solicitar-agendamento";
    }

    @PostMapping("/agendamentos/solicitar")
    public String solicitarAgendamento(
            @Valid @ModelAttribute("form") ClienteSolicitarAgendamentoForm form,
            BindingResult bindingResult,
            Model model,
            RedirectAttributes redirectAttributes) {

        Sala sala = salaService.findById(form.getSalaId())
                .orElseThrow(() -> new IllegalArgumentException("Sala não encontrada"));
        model.addAttribute("sala", sala);

        if (bindingResult.hasErrors()) {
            return "cliente/solicitar-agendamento";
        }

        try {
            Cliente cliente = clienteService.getClienteLogado()
                    .orElseThrow(() -> new IllegalArgumentException("Cliente não encontrado. Faça login novamente."));

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
            LocalDateTime dataHoraInicio = LocalDateTime.parse(form.getDataHoraInicio(), formatter);
            LocalDateTime dataHoraFim = LocalDateTime.parse(form.getDataHoraFim(), formatter);

            LocalDateTime atual = LocalDateTime.now();
            if (!dataHoraInicio.isAfter(atual)) {
                model.addAttribute("error",
                        "Data/hora de início não pode ser no passado");
                return "cliente/solicitar-agendamento";
            }
            if (!dataHoraFim.isAfter(dataHoraInicio)) {
                model.addAttribute("error", "Data/hora de fim deve ser após a data/hora de início.");
                return "cliente/solicitar-agendamento";
            }
            agendamentoService.criarAgendamento(form.getSalaId(), cliente.getId(), dataHoraInicio, dataHoraFim,
                    form.getObservacoes());

            redirectAttributes.addFlashAttribute("success", "Solicitação de agendamento criada com sucesso");
            return "redirect:/cliente/agendamentos";
        } catch (IllegalArgumentException e) {
            model.addAttribute("error", e.getMessage());
            return "cliente/solicitar-agendamento";
        } catch (Exception e) {
            model.addAttribute("error", "Erro inesperado ao criar agendamento: " + e.getMessage());
            return "cliente/solicitar-agendamento";
        }
    }

    @GetMapping("/agendamentos")
    public String listarAgendamentos(Model model, RedirectAttributes redirectAttributes) {
        try {
            Cliente cliente = clienteService.getClienteLogado()
                    .orElseThrow(() -> new IllegalArgumentException("Cliente não encontrado. Faça login novamente."));

            List<Agendamento> agendamentos = agendamentoService.findByClienteId(cliente.getId());
            model.addAttribute("agendamentos", agendamentos);
            model.addAttribute("clienteId", cliente.getId());
            return "cliente/agendamentos";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/cliente";
        }
    }

    @PostMapping("/agendamentos/cancelar")
    public String cancelarAgendamento(@RequestParam Long agendamentoId, RedirectAttributes redirectAttributes) {
        try {
            clienteService.getClienteLogado()
                    .orElseThrow(() -> new IllegalArgumentException("Cliente não encontrado. Faça login novamente."));

            agendamentoService.cancelarAgendamento(agendamentoId);
            redirectAttributes.addFlashAttribute("success", "Agendamento cancelado com sucesso");
            return "redirect:/cliente/agendamentos";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/cliente/agendamentos";
        }
    }

    @GetMapping("/historico")
    public String historico(Model model, RedirectAttributes redirectAttributes) {
        try {
            Cliente cliente = clienteService.getClienteLogado()
                    .orElseThrow(() -> new IllegalArgumentException("Cliente não encontrado. Faça login novamente."));
            var historico = relatorioService.historicoPorCliente(cliente.getId());
            model.addAttribute("historicos", historico);
            return "cliente/historico";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/cliente";
        }
    }

    @GetMapping("/salas/disponibilidade")
    public String verificarDisponibilidade(
            @RequestParam Long salaId,
            @RequestParam String dataInicio,
            @RequestParam String dataFim,
            Model model,
            RedirectAttributes redirectAttributes) {

        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
            LocalDateTime dataHoraInicio = LocalDateTime.parse(dataInicio, formatter);
            LocalDateTime dataHoraFim = LocalDateTime.parse(dataFim, formatter);

            Sala sala = salaService.findById(salaId)
                    .orElseThrow(() -> new IllegalArgumentException("Sala não encontrada"));

            List<Agendamento> conflitos = agendamentoService.findConflitosAgendamento(salaId, dataHoraInicio,
                    dataHoraFim);
            boolean disponivel = conflitos.isEmpty();

            model.addAttribute("sala", sala);
            model.addAttribute("dataInicio", dataHoraInicio);
            model.addAttribute("dataFim", dataHoraFim);
            model.addAttribute("disponivel", disponivel);
            model.addAttribute("conflitos", conflitos);

            return "cliente/disponibilidade";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/cliente/salas";
        }
    }
}
