package com.example.desafio_dunnas.domain.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.example.desafio_dunnas.domain.entity.Sala;

@Repository
public interface SalaRepository extends JpaRepository<Sala, Long> {

        List<Sala> findBySetorIdAndAtivaTrue(Long setorId);

        List<Sala> findByAtivaTrue();

        @Query("SELECT s FROM Sala s WHERE s.setor.id = :setorId AND s.ativa = true ORDER BY s.nome")
        List<Sala> findSalasAtivasPorSetor(@Param("setorId") Long setorId);

        @Query("SELECT s FROM Sala s WHERE s.setor.id = :setorId AND s.ativa = true AND s.setor.aberto = true ORDER BY s.nome")
        List<Sala> findSalasAtivasPorSetorAberto(@Param("setorId") Long setorId);

        @Query("SELECT s FROM Sala s WHERE s.ativa = true ORDER BY s.setor.nome, s.nome")
        List<Sala> findAllSalasAtivas();

        @Query("SELECT s FROM Sala s WHERE s.ativa = true AND s.setor.aberto = true ORDER BY s.setor.nome, s.nome")
        List<Sala> findSalasAtivasDeSetoresAbertos();

        boolean existsByNomeAndSetorId(String nome, Long setorId);

        boolean existsByNomeAndSetorIdAndIdNot(String nome, Long setorId, Long id);

        Optional<Sala> findByNomeAndSetorId(String nome, Long setorId);

        @Transactional
        @Modifying
        @Query(value = "CALL pr_create_sala(:p_nome, :p_valor_por_hora, :p_capacidade_maxima, :p_setor_id, :p_ativa)", nativeQuery = true)
        void criarSala(
                        @Param("p_nome") String nome,
                        @Param("p_valor_por_hora") java.math.BigDecimal valorPorHora,
                        @Param("p_capacidade_maxima") Integer capacidadeMaxima,
                        @Param("p_setor_id") Long setorId,
                        @Param("p_ativa") Boolean ativa);

        @Transactional
        @Modifying
        @Query(value = "CALL pr_update_sala(:p_sala_id, :p_nome, :p_valor_por_hora, :p_capacidade_maxima, :p_ativa, :p_setor_id)", nativeQuery = true)
        void atualizarSala(
                        @Param("p_sala_id") Long id,
                        @Param("p_nome") String nome,
                        @Param("p_valor_por_hora") java.math.BigDecimal valorPorHora,
                        @Param("p_capacidade_maxima") Integer capacidadeMaxima,
                        @Param("p_ativa") Boolean ativa,
                        @Param("p_setor_id") Long setorId);
}
