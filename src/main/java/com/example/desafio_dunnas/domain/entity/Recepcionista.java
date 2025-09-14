package com.example.desafio_dunnas.domain.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "tb_recepcionistas")
@Getter
@Setter
public class Recepcionista {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(optional = false)
    @JoinColumn(name = "usuario_id", nullable = false, unique = true)
    private Usuario usuario;

    // mapeamento simples do setor_id como coluna (evita depender da entidade Setor
    // aqui)
    @Column(name = "setor_id", nullable = false, unique = true)
    private Long setorId;

    @Column(nullable = false, unique = true, length = 20)
    private String matricula;

    @Column(unique = true, length = 11)
    private String cpf;
}
