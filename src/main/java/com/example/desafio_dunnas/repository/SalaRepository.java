package com.example.desafio_dunnas.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.example.desafio_dunnas.model.Sala;

@Repository
public interface SalaRepository extends JpaRepository<Sala, Long> {

        // Consultas que consideram soft delete (apenas salas não excluídas)
        @Query("SELECT s FROM Sala s WHERE s.setor.id = :setorId AND s.ativa = true AND s.deletedAt IS NULL ORDER BY s.nome")
        List<Sala> findSalasAtivasPorSetor(@Param("setorId") Long setorId);

        @Query("SELECT s FROM Sala s WHERE s.setor.id = :setorId AND s.ativa = true AND s.setor.aberto = true AND s.deletedAt IS NULL ORDER BY s.nome")
        List<Sala> findSalasAtivasPorSetorAberto(@Param("setorId") Long setorId);

        @Query("SELECT s FROM Sala s WHERE s.ativa = true AND s.deletedAt IS NULL ORDER BY s.setor.nome, s.nome")
        List<Sala> findAllSalasAtivas();

        @Query("SELECT s FROM Sala s WHERE s.ativa = true AND s.setor.aberto = true AND s.deletedAt IS NULL ORDER BY s.setor.nome, s.nome")
        List<Sala> findSalasAtivasDeSetoresAbertos();

        // Consultas que incluem salas soft deleted (para administração)
        @Query("SELECT s FROM Sala s WHERE s.deletedAt IS NULL ORDER BY s.setor.nome, s.nome")
        List<Sala> findAllNaoExcluidas();

        @Query("SELECT s FROM Sala s WHERE s.deletedAt IS NOT NULL ORDER BY s.deletedAt DESC")
        List<Sala> findAllExcluidas();

        // Procedures para operações CRUD
        @Transactional
        @Modifying
        @Query(value = "CALL pr_create_sala(:p_nome, :p_valor_por_hora, :p_capacidade_maxima, :p_setor_id)", nativeQuery = true)
        void criarSala(
                        @Param("p_nome") String nome,
                        @Param("p_valor_por_hora") java.math.BigDecimal valorPorHora,
                        @Param("p_capacidade_maxima") Integer capacidadeMaxima,
                        @Param("p_setor_id") Long setorId);

        @Transactional
        @Modifying
        @Query(value = "CALL pr_update_sala(:p_sala_id, :p_nome, :p_valor_por_hora, :p_capacidade_maxima, :p_ativa)", nativeQuery = true)
        void atualizarSala(
                        @Param("p_sala_id") Long id,
                        @Param("p_nome") String nome,
                        @Param("p_valor_por_hora") java.math.BigDecimal valorPorHora,
                        @Param("p_capacidade_maxima") Integer capacidadeMaxima,
                        @Param("p_ativa") Boolean ativa);

        @Transactional
        @Modifying
        @Query(value = "CALL pr_soft_delete_sala(:p_sala_id, :p_deleted_by)", nativeQuery = true)
        void softDeleteSala(@Param("p_sala_id") Long salaId, @Param("p_deleted_by") Long deletedBy);
}
