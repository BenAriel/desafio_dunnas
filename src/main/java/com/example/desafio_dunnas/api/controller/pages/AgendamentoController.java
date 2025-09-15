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

import com.example.desafio_dunnas.domain.entity.Agendamento;
import com.example.desafio_dunnas.domain.entity.Agendamento.StatusAgendamento;
import com.example.desafio_dunnas.domain.entity.Cliente;
import com.example.desafio_dunnas.domain.entity.Sala;
import com.example.desafio_dunnas.domain.service.AgendamentoService;
import com.example.desafio_dunnas.domain.service.ClienteService;
import com.example.desafio_dunnas.domain.service.SalaService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/agendamentos")
@RequiredArgsConstructor
public class AgendamentoController {

    private final AgendamentoService agendamentoService;
    private final SalaService salaService;
    private final ClienteService clienteService;

    @GetMapping({ "", "/" })
    public String listarAgendamentos(Model model) {
        List<Agendamento> agendamentos = agendamentoService.findAll();
        model.addAttribute("agendamentos", agendamentos);
        return "agendamentos/lista";
    }

    @GetMapping("/solicitar")
    public String solicitarForm(Model model) {
        List<Sala> salas = salaService.findSalasAtivas();
        model.addAttribute("salas", salas);
        model.addAttribute("agendamento", new Agendamento());
        return "agendamentos/solicitar";
    }

    @PostMapping("/solicitar")
    public String solicitar(
            @RequestParam("salaId") Long salaId,
            @RequestParam("clienteId") Long clienteId,
            @RequestParam("dataHoraInicio") String dataHoraInicioStr,
            @RequestParam("dataHoraFim") String dataHoraFimStr,
            @RequestParam(value = "observacoes", required = false) String observacoes) {
        
        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
            LocalDateTime dataHoraInicio = LocalDateTime.parse(dataHoraInicioStr, formatter);
            LocalDateTime dataHoraFim = LocalDateTime.parse(dataHoraFimStr, formatter);

            agendamentoService.criarAgendamento(salaId, clienteId, dataHoraInicio, dataHoraFim, observacoes);
            
            return "redirect:/agendamentos?success=Solicitação de agendamento criada com sucesso";
        } catch (Exception e) {
            return "redirect:/agendamentos/solicitar?error=" + e.getMessage();
        }
    }

    @GetMapping("/recepcionista")
    public String listarParaRecepcionista(@RequestParam Long setorId, Model model) {
        List<Agendamento> solicitados = agendamentoService.findBySetorIdAndStatus(setorId, StatusAgendamento.SOLICITADO);
        List<Agendamento> confirmados = agendamentoService.findBySetorIdAndStatus(setorId, StatusAgendamento.CONFIRMADO);
        List<Agendamento> finalizados = agendamentoService.findBySetorIdAndStatus(setorId, StatusAgendamento.FINALIZADO);
        
        model.addAttribute("solicitados", solicitados);
        model.addAttribute("confirmados", confirmados);
        model.addAttribute("finalizados", finalizados);
        model.addAttribute("setorId", setorId);
        
        return "recepcionista/agendamentos";
    }

    @PostMapping("/confirmar")
    public String confirmar(@RequestParam Long agendamentoId) {
        try {
            agendamentoService.confirmarAgendamento(agendamentoId);
            return "redirect:/recepcionista/agendamentos?success=Agendamento confirmado com sucesso";
        } catch (Exception e) {
            return "redirect:/recepcionista/agendamentos?error=" + e.getMessage();
        }
    }

    @PostMapping("/finalizar")
    public String finalizar(@RequestParam Long agendamentoId) {
        try {
            agendamentoService.finalizarAgendamento(agendamentoId);
            return "redirect:/recepcionista/agendamentos?success=Agendamento finalizado com sucesso";
        } catch (Exception e) {
            return "redirect:/recepcionista/agendamentos?error=" + e.getMessage();
        }
    }

    @PostMapping("/cancelar")
    public String cancelar(@RequestParam Long agendamentoId) {
        try {
            agendamentoService.cancelarAgendamento(agendamentoId);
            return "redirect:/agendamentos?success=Agendamento cancelado com sucesso";
        } catch (Exception e) {
            return "redirect:/agendamentos?error=" + e.getMessage();
        }
    }

    @GetMapping("/cliente")
    public String listarPorCliente(@RequestParam Long clienteId, Model model) {
        List<Agendamento> agendamentos = agendamentoService.findByClienteId(clienteId);
        model.addAttribute("agendamentos", agendamentos);
        model.addAttribute("clienteId", clienteId);
        return "cliente/agendamentos";
    }

    @GetMapping("/instantaneo")
    public String agendamentoInstantaneoForm(@RequestParam Long setorId, Model model) {
        List<Sala> salas = salaService.findSalasAtivasPorSetor(setorId);
        List<Cliente> clientes = clienteService.findAll();
        
        model.addAttribute("salas", salas);
        model.addAttribute("clientes", clientes);
        model.addAttribute("setorId", setorId);
        model.addAttribute("agendamento", new Agendamento());
        
        return "recepcionista/agendamento-instantaneo";
    }

    @PostMapping("/instantaneo")
    public String agendamentoInstantaneo(
            @RequestParam("salaId") Long salaId,
            @RequestParam("clienteId") Long clienteId,
            @RequestParam("dataHoraInicio") String dataHoraInicioStr,
            @RequestParam("dataHoraFim") String dataHoraFimStr,
            @RequestParam(value = "observacoes", required = false) String observacoes,
            @RequestParam Long setorId) {
        
        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
            LocalDateTime dataHoraInicio = LocalDateTime.parse(dataHoraInicioStr, formatter);
            LocalDateTime dataHoraFim = LocalDateTime.parse(dataHoraFimStr, formatter);

            Agendamento agendamento = new Agendamento();
            
            Sala sala = new Sala();
            sala.setId(salaId);
            agendamento.setSala(sala);
            
            Cliente cliente = new Cliente();
            cliente.setId(clienteId);
            agendamento.setCliente(cliente);
            
            agendamento.setDataHoraInicio(dataHoraInicio);
            agendamento.setDataHoraFim(dataHoraFim);
            agendamento.setObservacoes(observacoes);

            // Salva e confirma automaticamente
            agendamento = agendamentoService.save(agendamento);
            agendamentoService.confirmarAgendamento(agendamento.getId());
            
            return "redirect:/recepcionista/agendamentos?success=Agendamento instantâneo criado e confirmado com sucesso";
        } catch (Exception e) {
            return "redirect:/agendamentos/instantaneo?setorId=" + setorId + "&error=" + e.getMessage();
        }
    }
}
