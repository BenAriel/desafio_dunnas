package com.example.desafio_dunnas.controller;

import java.math.BigDecimal;
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
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.PageRequest;

import com.example.desafio_dunnas.config.DbErrorMessageResolver;
import com.example.desafio_dunnas.dto.relatorio.RelatorioFiltroDTO;
import com.example.desafio_dunnas.form.recepcionista.RecepcionistaForm;
import com.example.desafio_dunnas.form.recepcionista.RecepcionistaEditForm;
import com.example.desafio_dunnas.form.sala.SalaForm;
import com.example.desafio_dunnas.form.setor.SetorForm;
import com.example.desafio_dunnas.model.Sala;
import com.example.desafio_dunnas.model.Setor;
import com.example.desafio_dunnas.model.Cliente;
import com.example.desafio_dunnas.service.AuthService;
import com.example.desafio_dunnas.service.RecepcionistaService;
import com.example.desafio_dunnas.service.SalaService;
import com.example.desafio_dunnas.service.SetorService;
import com.example.desafio_dunnas.service.ClienteService;
import com.example.desafio_dunnas.service.RelatorioService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdministradorController {

    private final RecepcionistaService recepcionistaService;
    private final SetorService setorService;
    private final SalaService salaService;
    private final RelatorioService relatorioAdminFacadeService;
    private final AuthService authUtils;

    private final ClienteService clienteService;

    @GetMapping({ "", "/" })
    public String adminHome() {
        return "admin/admin";
    }

    // ========== RECEPCIONISTAS ==========
    @GetMapping("/recepcionistas")
    public String listarRecepcionistas(@RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            Model model) {
        var pageable = PageRequest.of(Math.max(page, 0), Math.max(size, 1));
        var receps = recepcionistaService.findAll(pageable);
        model.addAttribute("recepcionistas", receps.getContent());
        model.addAttribute("page", receps);
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

    @GetMapping("/recepcionistas/editar")
    public String editarRecepcionistaForm(@RequestParam Long id, Model model, RedirectAttributes redirectAttributes) {
        try {
            var r = recepcionistaService.findById(id);
            RecepcionistaEditForm form = new RecepcionistaEditForm();
            form.setRecepcionistaId(r.getId());
            form.setUsuarioId(r.getUsuario().getId());
            form.setNome(r.getUsuario().getNome());
            form.setEmail(r.getUsuario().getEmail());
            form.setSetorId(r.getSetor().getId());
            form.setMatricula(r.getMatricula());
            form.setCpf(r.getCpf());
            model.addAttribute("form", form);
            model.addAttribute("setores", setorService.findAllNaoExcluidos());
            return "admin/recepcionista-edit-form";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/admin/recepcionistas";
        }
    }

    @PostMapping("/recepcionistas/atualizar")
    public String atualizarRecepcionista(
            @Valid @ModelAttribute("form") RecepcionistaEditForm form,
            BindingResult bindingResult,
            Model model,
            RedirectAttributes redirectAttributes) {
        if (bindingResult.hasErrors()) {
            model.addAttribute("setores", setorService.findAllNaoExcluidos());
            return "admin/recepcionista-edit-form";
        }
        try {
            recepcionistaService.atualizarRecepcionista(form.getUsuarioId(), form.getNome(), form.getEmail(),
                    form.getSenha(), form.getSetorId(), form.getMatricula(), form.getCpf());
            redirectAttributes.addFlashAttribute("success", "Recepcionista atualizado com sucesso");
            return "redirect:/admin/recepcionistas";
        } catch (DataIntegrityViolationException ex) {
            model.addAttribute("error", DbErrorMessageResolver.resolve(ex));
            model.addAttribute("clientes", clienteService.findAll());
            model.addAttribute("setores", setorService.findAllNaoExcluidos());
            return "admin/recepcionista-edit-form";
        } catch (Exception e) {
            model.addAttribute("error", DbErrorMessageResolver.resolve(e));
            model.addAttribute("setores", setorService.findAllNaoExcluidos());
            return "admin/recepcionista-edit-form";
        }
    }

    @PostMapping("/recepcionistas/excluir")
    public String excluirRecepcionista(@RequestParam Long id, RedirectAttributes redirectAttributes) {
        try {
            recepcionistaService.excluirRecepcionista(id);
            redirectAttributes.addFlashAttribute("success", "Recepcionista excluído com sucesso");
        } catch (DataIntegrityViolationException ex) {
            redirectAttributes.addFlashAttribute("error", DbErrorMessageResolver.resolve(ex));
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", DbErrorMessageResolver.resolve(e));
        }
        return "redirect:/admin/recepcionistas";
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
        } catch (DataIntegrityViolationException ex) {
            model.addAttribute("error", DbErrorMessageResolver.resolve(ex));
            model.addAttribute("setores", setorService.findSetoresSemRecepcionista());
            return "admin/recepcionista-form-com-usuario";
        } catch (IllegalArgumentException e) {
            model.addAttribute("error", e.getMessage());
            model.addAttribute("setores", setorService.findSetoresSemRecepcionista());
            return "admin/recepcionista-form-com-usuario";
        } catch (Exception e) {
            model.addAttribute("error", DbErrorMessageResolver.resolve(e));
            model.addAttribute("setores", setorService.findSetoresSemRecepcionista());
            return "admin/recepcionista-form-com-usuario";
        }
    }

    // ========== SETORES ==========
    @GetMapping("/setores")
    public String listarSetores(@RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            Model model) {
        var pageable = PageRequest.of(Math.max(page, 0), Math.max(size, 1));
        var setores = setorService.findAllNaoExcluidos(pageable);
        model.addAttribute("setores", setores.getContent());
        model.addAttribute("page", setores);
        return "admin/setores";
    }

    @GetMapping("/setores/excluidos")
    public String listarSetoresExcluidos(@RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "5") int size,
            Model model) {
        var pageable = PageRequest.of(Math.max(page, 0), Math.max(size, 1));
        var setores = setorService.findAllExcluidos(pageable);
        model.addAttribute("setores", setores.getContent());
        model.addAttribute("page", setores);
        return "admin/setores-excluidos";
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
        } catch (DataIntegrityViolationException ex) {
            model.addAttribute("error", DbErrorMessageResolver.resolve(ex));
            return "admin/setor-form";
        } catch (IllegalArgumentException e) {
            model.addAttribute("error", e.getMessage());
            return "admin/setor-form";
        } catch (Exception e) {
            model.addAttribute("error", DbErrorMessageResolver.resolve(e));
            return "admin/setor-form";
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
            Long adminId = authUtils.requireUsuarioId();
            setorService.softDeleteSetor(id, adminId);
            redirectAttributes.addFlashAttribute("success", "Setor excluído com sucesso");
        } catch (DataIntegrityViolationException ex) {
            redirectAttributes.addFlashAttribute("error",
                    "Erro ao excluir setor: " + DbErrorMessageResolver.resolve(ex));
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error",
                    "Erro ao excluir setor: " + DbErrorMessageResolver.resolve(e));
        }
        return "redirect:/admin/setores";
    }

    @PostMapping("/setores/reativar")
    public String reativarSetor(@RequestParam Long id, RedirectAttributes redirectAttributes) {
        try {
            Long adminId = authUtils.requireUsuarioId();
            setorService.reativarSetor(id, adminId);
            redirectAttributes.addFlashAttribute("success", "Setor reativado com sucesso");
        } catch (DataIntegrityViolationException ex) {
            redirectAttributes.addFlashAttribute("error",
                    "Erro ao reativar setor: " + DbErrorMessageResolver.resolve(ex));
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error",
                    "Erro ao reativar setor: " + DbErrorMessageResolver.resolve(e));
        }
        return "redirect:/admin/setores/excluidos";
    }

    // ========== SALAS ==========
    @GetMapping("/salas")
    public String listarSalas(@RequestParam(required = false) Long setorId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            Model model) {
        var pageable = PageRequest.of(Math.max(page, 0), Math.max(size, 1));
        var salas = salaService.findAllNaoExcluidasBySetor(setorId, pageable);
        List<Setor> setores = setorService.findAllNaoExcluidos();
        model.addAttribute("setores", setores);
        model.addAttribute("setorId", setorId);
        model.addAttribute("salas", salas.getContent());
        model.addAttribute("page", salas);
        return "admin/salas";
    }

    @GetMapping("/salas/novo")
    public String novaSalaForm(Model model) {
        List<Setor> setores = setorService.findAllNaoExcluidos();
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

        List<Setor> setores = setorService.findAllNaoExcluidos();
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
            model.addAttribute("setores", setorService.findAllNaoExcluidos());
            return "admin/sala-form";
        }
        try {
            if (form.getId() != null) {
                salaService.atualizarSala(form.getId(), form.getNome(), form.getValorPorHora(),
                        form.getCapacidadeMaxima(), Boolean.TRUE.equals(form.getAtiva()));
            } else {
                salaService.criarSala(form.getNome(), form.getValorPorHora(), form.getCapacidadeMaxima(),
                        form.getSetorId());
            }
            redirectAttributes.addFlashAttribute("success", "Sala salva com sucesso");
            return "redirect:/admin/salas";
        } catch (DataIntegrityViolationException ex) {
            model.addAttribute("error", DbErrorMessageResolver.resolve(ex));
            model.addAttribute("setores", setorService.findAllNaoExcluidos());
            return "admin/sala-form";
        } catch (IllegalArgumentException e) {
            model.addAttribute("error", e.getMessage());
            model.addAttribute("setores", setorService.findAllNaoExcluidos());
            return "admin/sala-form";
        } catch (Exception e) {
            model.addAttribute("error", DbErrorMessageResolver.resolve(e));
            model.addAttribute("setores", setorService.findAllNaoExcluidos());
            return "admin/sala-form";
        }
    }

    @PostMapping("/salas/excluir")
    public String excluirSala(@RequestParam Long id, RedirectAttributes redirectAttributes) {
        try {
            Long adminId = authUtils.requireUsuarioId();
            salaService.softDeleteSala(id, adminId);
            redirectAttributes.addFlashAttribute("success", "Sala excluída com sucesso");
        } catch (DataIntegrityViolationException ex) {
            redirectAttributes.addFlashAttribute("error",
                    "Erro ao excluir sala: " + DbErrorMessageResolver.resolve(ex));
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Erro ao excluir sala: " + DbErrorMessageResolver.resolve(e));
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
            @RequestParam(defaultValue = "0") int agPage,
            @RequestParam(defaultValue = "5") int agSize,
            @RequestParam(defaultValue = "0") int histPage,
            @RequestParam(defaultValue = "5") int histSize,
            @RequestParam(defaultValue = "0") int txPage,
            @RequestParam(defaultValue = "5") int txSize,
            Model model) {

        List<Cliente> clientes = clienteService.findAll();
        List<Setor> setores = setorService.findAllNaoExcluidos();
        model.addAttribute("setores", setores);
        model.addAttribute("setorId", setorId);
        model.addAttribute("status", status);
        model.addAttribute("clientes", clientes);
        model.addAttribute("clienteId", clienteId);

        try {
            var result = relatorioAdminFacadeService.gerarRelatorio(
                    RelatorioFiltroDTO.builder()
                            .setorId(setorId)
                            .dataInicio(dataInicio)
                            .dataFim(dataFim)
                            .status(status)
                            .clienteId(clienteId)
                            .agPage(agPage)
                            .agSize(agSize)
                            .histPage(histPage)
                            .histSize(histSize)
                            .txPage(txPage)
                            .txSize(txSize)
                            .build());

            model.addAttribute("dataInicio", result.getDataInicioStr());
            model.addAttribute("dataFim", result.getDataFimStr());
            model.addAttribute("agendamentos", result.getAgendamentos());
            model.addAttribute("agPage", result.getAgPage());
            model.addAttribute("transacoes", result.getTransacoes());
            model.addAttribute("txPage", result.getTxPage());
            model.addAttribute("valorCaixa", result.getValorCaixa());
            model.addAttribute("historicos", result.getHistoricos());
            model.addAttribute("histPage", result.getHistPage());
        } catch (Exception e) {
            model.addAttribute("error", DbErrorMessageResolver.resolve(e));
        }

        return "admin/relatorio-geral";
    }
}
