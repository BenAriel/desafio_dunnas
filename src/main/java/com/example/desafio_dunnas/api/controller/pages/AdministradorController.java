package com.example.desafio_dunnas.api.controller.pages;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.validation.BindingResult;
import jakarta.validation.Valid;

import com.example.desafio_dunnas.api.dto.recepcionista.RecepcionistaForm;
import com.example.desafio_dunnas.api.dto.sala.SalaForm;
import com.example.desafio_dunnas.api.dto.setor.SetorForm;
import com.example.desafio_dunnas.domain.entity.Agendamento.StatusAgendamento;
import com.example.desafio_dunnas.domain.entity.Recepcionista;
import com.example.desafio_dunnas.domain.entity.Sala;
import com.example.desafio_dunnas.domain.entity.Setor;
import com.example.desafio_dunnas.domain.service.RecepcionistaService;
import com.example.desafio_dunnas.domain.service.RelatorioService;
import com.example.desafio_dunnas.domain.service.SalaService;
import com.example.desafio_dunnas.domain.service.SetorService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdministradorController {

    private final RecepcionistaService recepcionistaService;
    private final SetorService setorService;
    private final SalaService salaService;
    private final RelatorioService relatorioService;

    @GetMapping({ "", "/" })
    public String adminHome() {
        return "admin/admin";
    }

    // ========== RECEPCIONISTAS ==========
    @GetMapping("/recepcionistas")
    public String listarRecepcionistas(Model model) {
        List<Recepcionista> recepcionistas = recepcionistaService.findAll();
        model.addAttribute("recepcionistas", recepcionistas);
        return "admin/recepcionistas";
    }

    @GetMapping("/recepcionistas/novo")
    public String novoRecepcionistaForm(Model model) {
        if (!model.containsAttribute("form")) {
            model.addAttribute("form", new RecepcionistaForm());
        }
        List<Setor> setores = setorService.findSetoresSemRecepcionista();
        model.addAttribute("setores", setores);
        return "admin/recepcionista-form-com-usuario";
    }

    @PostMapping("/recepcionistas/criar")
    public String criarRecepcionista(
            @Valid @ModelAttribute("form") RecepcionistaForm form,
            BindingResult bindingResult,
            Model model,
            RedirectAttributes redirectAttributes) {
        if (bindingResult.hasErrors()) {
            model.addAttribute("setores", setorService.findSetoresSemRecepcionista());
            return "admin/recepcionista-form-com-usuario";
        }
        try {
            recepcionistaService.cadastrarUsuarioERecepcionista(
                    form.getNome(), form.getEmail(), form.getSenha(),
                    form.getSetorId(), form.getMatricula(), form.getCpf());
            redirectAttributes.addFlashAttribute("success", "Recepcionista criado com sucesso");
            return "redirect:/admin/recepcionistas";
        } catch (IllegalArgumentException e) {
            model.addAttribute("error", e.getMessage());
            model.addAttribute("setores", setorService.findSetoresSemRecepcionista());
            return "admin/recepcionista-form-com-usuario";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Erro inesperado: " + e.getMessage());
            return "redirect:/admin/recepcionistas";
        }
    }

    // ========== SETORES ==========
    @GetMapping("/setores")
    public String listarSetores(Model model) {
        List<Setor> setores = setorService.findAll();
        model.addAttribute("setores", setores);
        return "admin/setores";
    }

    @GetMapping("/setores/novo")
    public String novoSetorForm(Model model) {
        if (!model.containsAttribute("form")) {
            SetorForm form = new SetorForm();
            form.setAberto(false);
            form.setCaixa(BigDecimal.ZERO);
            model.addAttribute("form", form);
        }
        return "admin/setor-form";
    }

    @PostMapping("/setores/salvar")
    public String salvarSetor(
            @Valid @ModelAttribute("form") SetorForm form,
            BindingResult bindingResult,
            Model model,
            RedirectAttributes redirectAttributes) {
        if (bindingResult.hasErrors()) {
            return "admin/setor-form";
        }
        try {
            if (form.getId() != null) {
                setorService.findById(form.getId())
                        .orElseThrow(() -> new IllegalArgumentException("Setor não encontrado"));
                setorService.updateSetor(form.getId(), form.getNome(), form.getCaixa(),
                        Boolean.TRUE.equals(form.getAberto()));
                redirectAttributes.addFlashAttribute("success", "Setor atualizado com sucesso");
            } else {

                setorService.criarSetor(form.getNome(), form.getCaixa(), Boolean.TRUE.equals(form.getAberto()));
                redirectAttributes.addFlashAttribute("success", "Setor criado com sucesso");
            }
            return "redirect:/admin/setores";
        } catch (IllegalArgumentException e) {
            model.addAttribute("error", e.getMessage());
            return "admin/setor-form";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Erro inesperado" + e.getMessage());
            return "redirect:/admin/setores";
        }
    }

    @GetMapping("/setores/editar")
    public String editarSetorForm(@RequestParam Long id, Model model) {
        Setor setor = setorService.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Setor não encontrado"));

        SetorForm form = new SetorForm();
        form.setId(setor.getId());
        form.setNome(setor.getNome());
        form.setCaixa(setor.getCaixa());
        form.setAberto(Boolean.TRUE.equals(setor.getAberto()));
        model.addAttribute("form", form);
        return "admin/setor-form";
    }

    @PostMapping("/setores/excluir")
    public String excluirSetor(@RequestParam Long id, RedirectAttributes redirectAttributes) {
        try {
            setorService.deleteById(id);
            redirectAttributes.addFlashAttribute("success", "Setor excluído com sucesso");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Erro ao excluir setor: " + e.getMessage());
        }
        return "redirect:/admin/setores";
    }

    // ========== SALAS ==========
    @GetMapping("/salas")
    public String listarSalas(Model model) {
        List<Sala> salas = salaService.findAll();
        model.addAttribute("salas", salas);
        return "admin/salas";
    }

    @GetMapping("/salas/novo")
    public String novaSalaForm(Model model) {
        List<Setor> setores = setorService.findAll();
        model.addAttribute("setores", setores);
        if (!model.containsAttribute("form")) {
            SalaForm form = new SalaForm();
            form.setAtiva(true);
            model.addAttribute("form", form);
        }
        return "admin/sala-form";
    }

    @GetMapping("/salas/editar")
    public String editarSalaForm(@RequestParam Long id, Model model) {
        Sala sala = salaService.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Sala não encontrada"));

        List<Setor> setores = setorService.findAll();
        model.addAttribute("setores", setores);
        SalaForm form = new SalaForm();
        form.setId(sala.getId());
        form.setNome(sala.getNome());
        form.setValorPorHora(sala.getValorPorHora());
        form.setCapacidadeMaxima(sala.getCapacidadeMaxima());
        form.setSetorId(sala.getSetor() != null ? sala.getSetor().getId() : null);
        form.setAtiva(Boolean.TRUE.equals(sala.getAtiva()));
        model.addAttribute("form", form);
        return "admin/sala-form";
    }

    @PostMapping("/salas/salvar")
    public String salvarSala(
            @Valid @ModelAttribute("form") SalaForm form,
            BindingResult bindingResult,
            Model model,
            RedirectAttributes redirectAttributes) {
        if (bindingResult.hasErrors()) {
            model.addAttribute("setores", setorService.findAll());
            return "admin/sala-form";
        }
        try {
            if (form.getId() != null) {
                salaService.atualizarSala(form.getId(), form.getNome(), form.getValorPorHora(),
                        form.getCapacidadeMaxima(), Boolean.TRUE.equals(form.getAtiva()), form.getSetorId());
            } else {
                salaService.criarSala(form.getNome(), form.getValorPorHora(), form.getCapacidadeMaxima(),
                        form.getSetorId(), Boolean.TRUE.equals(form.getAtiva()));
            }
            redirectAttributes.addFlashAttribute("success", "Sala salva com sucesso");
            return "redirect:/admin/salas";
        } catch (IllegalArgumentException e) {
            model.addAttribute("error", e.getMessage());
            model.addAttribute("setores", setorService.findAll());
            return "admin/sala-form";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Erro inesperado");
            return "redirect:/admin/salas";
        }
    }

    @PostMapping("/salas/excluir")
    public String excluirSala(@RequestParam Long id, RedirectAttributes redirectAttributes) {
        try {
            salaService.deleteById(id);
            redirectAttributes.addFlashAttribute("success", "Sala excluída com sucesso");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Erro ao excluir sala: " + e.getMessage());
        }
        return "redirect:/admin/salas";
    }

    // ========== RELATÓRIOS ==========

    @GetMapping("/relatorios")
    public String relatorioGeral(
            @RequestParam(required = false) Long setorId,
            @RequestParam(required = false) String dataInicio,
            @RequestParam(required = false) String dataFim,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Long clienteId,
            Model model) {

        List<Setor> setores = setorService.findAll();
        model.addAttribute("setores", setores);
        model.addAttribute("setorId", setorId);
        model.addAttribute("status", status);
        model.addAttribute("clienteId", clienteId);

        try {
            LocalDate ini = (dataInicio != null && !dataInicio.isBlank())
                    ? LocalDate.parse(dataInicio)
                    : LocalDate.now().minusDays(30);
            LocalDate fimD = (dataFim != null && !dataFim.isBlank())
                    ? LocalDate.parse(dataFim)
                    : LocalDate.now();

            LocalDateTime inicio = ini.atStartOfDay();
            LocalDateTime fim = fimD.atTime(23, 59, 59);

            model.addAttribute("dataInicio", ini.toString());
            model.addAttribute("dataFim", fimD.toString());

            var agendamentos = relatorioService.agendamentosPorPeriodoSetor(setorId, inicio, fim);
            if (status != null && !status.isBlank() && !"TODOS".equalsIgnoreCase(status)) {
                try {
                    StatusAgendamento st = StatusAgendamento.valueOf(status.toUpperCase());
                    agendamentos = agendamentos.stream().filter(a -> a.getStatus() == st).toList();
                } catch (IllegalArgumentException ignore) {
                }
            }
            if (clienteId != null) {
                Long cid = clienteId;
                agendamentos = agendamentos.stream()
                        .filter(a -> a.getCliente() != null && a.getCliente().getId().equals(cid)).toList();
            }
            var transacoes = relatorioService.transacoesConfirmadasPorPeriodoSetor(setorId, inicio, fim);
            var valorTotal = relatorioService.valorTransacoesConfirmadasPorPeriodoSetor(setorId, inicio, fim);

            model.addAttribute("agendamentos", agendamentos);
            model.addAttribute("transacoes", transacoes);
            model.addAttribute("valorTotal", valorTotal);

            if (setorId != null) {
                var historicosSetor = relatorioService.historicoPorSetor(setorId);
                var historicosFiltrados = historicosSetor.stream()
                        .filter(h -> !h.getDataMudanca().isBefore(inicio) && !h.getDataMudanca().isAfter(fim))
                        .toList();
                model.addAttribute("historicos", historicosFiltrados);
            } else {
                var historicos = relatorioService.historicoPorPeriodo(inicio, fim);
                model.addAttribute("historicos", historicos);
            }

        } catch (Exception e) {
            model.addAttribute("error", "Erro ao carregar relatório: " + e.getMessage());
        }

        return "admin/relatorio-geral";
    }
}
