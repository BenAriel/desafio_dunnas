package com.example.desafio_dunnas.domain.entity;

import java.math.BigDecimal;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "tb_salas")
@Getter
@Setter
public class Sala {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String nome;

    @Column(name = "valor_por_hora", nullable = false)
    private BigDecimal valorPorHora;

    @Column(nullable = false)
    private Integer capacidadeMaxima;

    @Column(nullable = false)
    private Boolean ativa = true;

    @ManyToOne(optional = false)
    @JoinColumn(name = "setor_id", nullable = false)
    private Setor setor;
}
