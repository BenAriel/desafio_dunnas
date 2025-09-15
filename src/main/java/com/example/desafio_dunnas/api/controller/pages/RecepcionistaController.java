package com.example.desafio_dunnas.api.controller.pages;

import java.time.LocalDateTime;
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

import com.example.desafio_dunnas.api.dto.agendamento.AgendamentoInstantaneoForm;
import com.example.desafio_dunnas.domain.entity.Agendamento;
import com.example.desafio_dunnas.domain.entity.Agendamento.StatusAgendamento;
import com.example.desafio_dunnas.domain.entity.Cliente;
import com.example.desafio_dunnas.domain.entity.Recepcionista;
import com.example.desafio_dunnas.domain.entity.Sala;
import com.example.desafio_dunnas.domain.entity.Setor;
import com.example.desafio_dunnas.domain.service.AgendamentoService;
import com.example.desafio_dunnas.domain.service.ClienteService;
import com.example.desafio_dunnas.domain.service.SalaService;
import com.example.desafio_dunnas.domain.service.SetorService;
import com.example.desafio_dunnas.domain.service.RecepcionistaService;
import java.util.Optional;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/recepcionista")
@RequiredArgsConstructor
public class RecepcionistaController {

    private final AgendamentoService agendamentoService;
    private final ClienteService clienteService;
    private final SalaService salaService;
    private final SetorService setorService;
    private final RecepcionistaService recepcionistaService;

    @GetMapping({ "", "/" })
    public String recepcionistaHome(Model model, RedirectAttributes redirectAttributes) {
        try {
            Optional<Recepcionista> opt = recepcionistaService.getRecepcionistaLogado();
            if (!opt.isPresent()) {
                redirectAttributes.addFlashAttribute("error", "Recepcionista não encontrado. Faça login novamente.");
                return "redirect:/login";
            }
            Recepcionista recepcionista = opt.get();
            Setor setor = recepcionista.getSetor();
            model.addAttribute("setor", setor);
            return "recepcionista/recepcionista";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/login";
        }
    }

    @GetMapping("/agendamentos")
    public String listarAgendamentos(@RequestParam(required = false) Long setorId, Model model,
            RedirectAttributes redirectAttributes) {
        try {
            if (setorId == null) {
                Optional<Recepcionista> opt = recepcionistaService
                        .getRecepcionistaLogado();
                if (!opt.isPresent() || opt.get().getSetor() == null) {
                    redirectAttributes.addFlashAttribute("error", "Setor do recepcionista não encontrado.");
                    return "redirect:/recepcionista";
                }
                setorId = opt.get().getSetor().getId();
            }

            List<Agendamento> solicitados = agendamentoService.findBySetorIdAndStatus(setorId,
                    StatusAgendamento.SOLICITADO);
            List<Agendamento> confirmados = agendamentoService.findBySetorIdAndStatus(setorId,
                    StatusAgendamento.CONFIRMADO);
            List<Agendamento> finalizados = agendamentoService.findBySetorIdAndStatus(setorId,
                    StatusAgendamento.FINALIZADO);

            model.addAttribute("solicitados", solicitados);
            model.addAttribute("confirmados", confirmados);
            model.addAttribute("finalizados", finalizados);
            model.addAttribute("setorId", setorId);

            return "recepcionista/agendamentos";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/recepcionista";
        }
    }

    @PostMapping("/agendamentos/confirmar")
    public String confirmarAgendamento(@RequestParam Long agendamentoId, @RequestParam Long setorId,
            RedirectAttributes redirectAttributes) {
        try {
            agendamentoService.confirmarAgendamento(agendamentoId);
            redirectAttributes.addFlashAttribute("success", "Agendamento confirmado com sucesso");
            return "redirect:/recepcionista/agendamentos?setorId=" + setorId;
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/recepcionista/agendamentos?setorId=" + setorId;
        }
    }

    @PostMapping("/agendamentos/finalizar")
    public String finalizarAgendamento(@RequestParam Long agendamentoId, @RequestParam Long setorId,
            RedirectAttributes redirectAttributes) {
        try {
            agendamentoService.finalizarAgendamento(agendamentoId);
            redirectAttributes.addFlashAttribute("success", "Agendamento finalizado com sucesso");
            return "redirect:/recepcionista/agendamentos?setorId=" + setorId;
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/recepcionista/agendamentos?setorId=" + setorId;
        }
    }

    @GetMapping("/agendamentos/instantaneo")
    public String agendamentoInstantaneoForm(@RequestParam(required = false) Long setorId, Model model,
            RedirectAttributes redirectAttributes) {
        try {
            if (setorId == null) {
                Optional<Recepcionista> opt = recepcionistaService
                        .getRecepcionistaLogado();
                if (!opt.isPresent() || opt.get().getSetor() == null) {
                    redirectAttributes.addFlashAttribute("error", "Setor do recepcionista não encontrado.");
                    return "redirect:/recepcionista";
                }
                setorId = opt.get().getSetor().getId();
            }

            List<Sala> salas = salaService.findSalasAtivasPorSetor(setorId);
            List<Cliente> clientes = clienteService.findAll();

            model.addAttribute("salas", salas);
            model.addAttribute("clientes", clientes);
            model.addAttribute("setorId", setorId);
            if (!model.containsAttribute("form")) {
                AgendamentoInstantaneoForm form = new AgendamentoInstantaneoForm();
                form.setSetorId(setorId);
                model.addAttribute("form", form);
            }

            return "recepcionista/agendamento-instantaneo";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/recepcionista";
        }
    }

    @PostMapping("/agendamentos/instantaneo")
    public String agendamentoInstantaneo(
            @Valid @ModelAttribute("form") AgendamentoInstantaneoForm form,
            BindingResult bindingResult,
            Model model,
            RedirectAttributes redirectAttributes) {
        Long setorId = form.getSetorId();
        List<Sala> salas = salaService.findSalasAtivasPorSetor(setorId);
        List<Cliente> clientes = clienteService.findAll();
        model.addAttribute("salas", salas);
        model.addAttribute("clientes", clientes);
        model.addAttribute("setorId", setorId);

        if (bindingResult.hasErrors()) {
            return "recepcionista/agendamento-instantaneo";
        }

        try {
            java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter
                    .ofPattern("yyyy-MM-dd'T'HH:mm");
            LocalDateTime dataHoraInicio = LocalDateTime.parse(form.getDataHoraInicio(), formatter);
            LocalDateTime dataHoraFim = LocalDateTime.parse(form.getDataHoraFim(), formatter);

            agendamentoService.criarAgendamento(form.getSalaId(), form.getClienteId(), dataHoraInicio, dataHoraFim,
                    form.getObservacoes());

            List<Agendamento> agendamentos = agendamentoService.findBySetorId(setorId);
            Agendamento ultimoAgendamento = agendamentos.stream()
                    .filter(a -> a.getSala().getId().equals(form.getSalaId()) &&
                            a.getCliente().getId().equals(form.getClienteId()) &&
                            a.getDataHoraInicio().equals(dataHoraInicio))
                    .findFirst()
                    .orElse(null);
            if (ultimoAgendamento != null) {
                agendamentoService.confirmarAgendamento(ultimoAgendamento.getId());
            }
            redirectAttributes.addFlashAttribute("success", "Agendamento instantâneo criado e confirmado com sucesso");
            return "redirect:/recepcionista/agendamentos?setorId=" + setorId;
        } catch (IllegalArgumentException e) {
            model.addAttribute("error", e.getMessage());
            return "recepcionista/agendamento-instantaneo";
        } catch (Exception e) {
            model.addAttribute("error", "Erro inesperado ao criar agendamento");
            return "recepcionista/agendamento-instantaneo";
        }
    }

    @GetMapping("/setor/abrir")
    public String abrirSetor(@RequestParam Long setorId, RedirectAttributes redirectAttributes) {
        try {
            setorService.abrirSetor(setorId);
            redirectAttributes.addFlashAttribute("success", "Setor aberto com sucesso");
            return "redirect:/recepcionista";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/recepcionista";
        }
    }

    @GetMapping("/setor/fechar")
    public String fecharSetor(@RequestParam Long setorId, RedirectAttributes redirectAttributes) {
        try {
            setorService.fecharSetor(setorId);
            redirectAttributes.addFlashAttribute("success", "Setor fechado com sucesso");
            return "redirect:/recepcionista";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/recepcionista";
        }
    }

    @GetMapping("/relatorios")
    public String relatorios(@RequestParam(required = false) Long setorId, Model model,
            RedirectAttributes redirectAttributes) {
        try {
            if (setorId == null) {
                Optional<Recepcionista> opt = recepcionistaService
                        .getRecepcionistaLogado();
                if (!opt.isPresent() || opt.get().getSetor() == null) {
                    redirectAttributes.addFlashAttribute("error", "Setor do recepcionista não encontrado.");
                    return "redirect:/recepcionista";
                }
                setorId = opt.get().getSetor().getId();
            }
            Setor setor = setorService.findById(setorId)
                    .orElseThrow(() -> new IllegalArgumentException("Setor não encontrado"));
            model.addAttribute("setor", setor);
            return "recepcionista/relatorios";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/recepcionista";
        }
    }
}
