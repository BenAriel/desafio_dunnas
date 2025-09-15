package com.example.desafio_dunnas.api.controller.pages;

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

import com.example.desafio_dunnas.api.dto.administrador.AdministradorForm;
import com.example.desafio_dunnas.api.dto.cliente.ClienteForm;
import com.example.desafio_dunnas.api.dto.recepcionista.RecepcionistaForm;
import com.example.desafio_dunnas.api.dto.sala.SalaForm;
import com.example.desafio_dunnas.api.dto.setor.SetorForm;
import com.example.desafio_dunnas.domain.entity.Cliente;
import com.example.desafio_dunnas.domain.entity.Recepcionista;
import com.example.desafio_dunnas.domain.entity.Sala;
import com.example.desafio_dunnas.domain.entity.Setor;
import com.example.desafio_dunnas.domain.service.AdministradorService;
import com.example.desafio_dunnas.domain.service.ClienteService;
import com.example.desafio_dunnas.domain.service.RecepcionistaService;
import com.example.desafio_dunnas.domain.service.SalaService;
import com.example.desafio_dunnas.domain.service.SetorService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdministradorController {

    private final AdministradorService administradorService;
    private final RecepcionistaService recepcionistaService;
    private final ClienteService clienteService;
    private final SetorService setorService;
    private final SalaService salaService;

    @GetMapping({ "", "/" })
    public String adminHome() {
        return "admin/admin";
    }

    // ========== ADMINISTRADORES ==========
    @GetMapping("/administradores")
    public String listarAdministradores() {
        return "admin/administradores";
    }

    @GetMapping("/administradores/novo")
    public String novoAdministradorForm(Model model) {
        if (!model.containsAttribute("form")) {
            model.addAttribute("form", new AdministradorForm());
        }
        return "admin/administrador-form-com-usuario";
    }

    @PostMapping("/administradores/criar")
    public String criarAdministrador(
            @Valid @ModelAttribute("form") AdministradorForm form,
            BindingResult bindingResult,
            Model model,
            RedirectAttributes redirectAttributes) {
        if (bindingResult.hasErrors()) {
            return "admin/administrador-form-com-usuario";
        }
        try {
            administradorService.cadastrarUsuarioEAdministrador(
                    form.getNome(), form.getEmail(), form.getSenha(), form.getMatricula(), form.getCpf());
            redirectAttributes.addFlashAttribute("success", "Administrador criado com sucesso");
            return "redirect:/admin/administradores";
        } catch (IllegalArgumentException e) {
            model.addAttribute("error", e.getMessage());
            return "admin/administrador-form-com-usuario";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Erro inesperado");
            return "redirect:/admin/administradores";
        }
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
            redirectAttributes.addFlashAttribute("error", "Erro inesperado");
            return "redirect:/admin/recepcionistas";
        }
    }

    // ========== CLIENTES ==========
    @GetMapping("/clientes")
    public String listarClientes(Model model) {
        List<Cliente> clientes = clienteService.findAll();
        model.addAttribute("clientes", clientes);
        return "admin/clientes";
    }

    @GetMapping("/clientes/novo")
    public String novoClienteForm(Model model) {
        if (!model.containsAttribute("form")) {
            model.addAttribute("form", new ClienteForm());
        }
        return "admin/cliente-form-com-usuario";
    }

    @PostMapping("/clientes/criar")
    public String criarCliente(
            @Valid @ModelAttribute("form") ClienteForm form,
            BindingResult bindingResult,
            Model model,
            RedirectAttributes redirectAttributes) {
        if (bindingResult.hasErrors()) {
            return "admin/cliente-form-com-usuario";
        }
        try {
            clienteService.cadastrarUsuarioECliente(
                    form.getNome(), form.getEmail(), form.getSenha(), form.getTelefone(), form.getProfissao());
            redirectAttributes.addFlashAttribute("success", "Cliente criado com sucesso");
            return "redirect:/admin/clientes";
        } catch (IllegalArgumentException e) {
            model.addAttribute("error", e.getMessage());
            return "admin/cliente-form-com-usuario";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Erro inesperado");
            return "redirect:/admin/clientes";
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
            redirectAttributes.addFlashAttribute("error", "Erro inesperado");
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
    public String excluirSetor(@RequestParam Long id) {
        try {
            setorService.deleteById(id);
            return "redirect:/admin/setores";
        } catch (Exception e) {
            return "redirect:/admin/setores";
        }
    }

    // ========== SALAS ==========
    @GetMapping("/salas")
    public String listarSalas(Model model) {
        List<Sala> salas = salaService.findSalasAtivas();
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
                        form.getCapacidadeMaxima(), Boolean.TRUE.equals(form.getAtiva()));
            } else {
                salaService.criarSala(form.getNome(), form.getValorPorHora(), form.getCapacidadeMaxima(),
                        form.getSetorId());
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
    public String excluirSala(@RequestParam Long id) {
        try {
            salaService.deleteById(id);
            return "redirect:/admin/salas?success=Sala excluída com sucesso";
        } catch (Exception e) {
            return "redirect:/admin/salas?error=" + e.getMessage();
        }
    }

    // ========== RELATÓRIOS ==========
    @GetMapping("/relatorios")
    public String relatorios() {
        return "admin/relatorios";
    }

    @GetMapping("/relatorios/agendamentos")
    public String relatorioAgendamentos(
            @RequestParam(required = false) Long setorId,
            @RequestParam(required = false) String dataInicio,
            @RequestParam(required = false) String dataFim,
            Model model) {

        List<Setor> setores = setorService.findAll();
        model.addAttribute("setores", setores);
        model.addAttribute("setorId", setorId);
        model.addAttribute("dataInicio", dataInicio);
        model.addAttribute("dataFim", dataFim);

        return "admin/relatorio-agendamentos";
    }

    @GetMapping("/relatorios/financeiro")
    public String relatorioFinanceiro(
            @RequestParam(required = false) Long setorId,
            @RequestParam(required = false) String dataInicio,
            @RequestParam(required = false) String dataFim,
            Model model) {

        List<Setor> setores = setorService.findAll();
        model.addAttribute("setores", setores);
        model.addAttribute("setorId", setorId);
        model.addAttribute("dataInicio", dataInicio);
        model.addAttribute("dataFim", dataFim);

        return "admin/relatorio-financeiro";
    }

    @GetMapping("/relatorios/clientes")
    public String relatorioClientes(
            @RequestParam(required = false) Long setorId,
            @RequestParam(required = false) String dataInicio,
            @RequestParam(required = false) String dataFim,
            Model model) {

        List<Setor> setores = setorService.findAll();
        model.addAttribute("setores", setores);
        model.addAttribute("setorId", setorId);
        model.addAttribute("dataInicio", dataInicio);
        model.addAttribute("dataFim", dataFim);

        return "admin/relatorio-clientes";
    }
}
