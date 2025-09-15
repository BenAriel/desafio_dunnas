package com.example.desafio_dunnas.domain.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.example.desafio_dunnas.domain.entity.Setor;

@Repository
public interface SetorRepository extends JpaRepository<Setor, Long> {

        List<Setor> findByAbertoTrue();

        List<Setor> findByAbertoFalse();

        @Query("SELECT s FROM Setor s WHERE s.id NOT IN (SELECT r.setor.id FROM Recepcionista r) ORDER BY s.nome")
        List<Setor> findSetoresSemRecepcionista();

        boolean existsByNome(String nome);

        boolean existsByNomeAndIdNot(String nome, Long id);

        @Transactional
        @Modifying
        @Query(value = "CALL pr_create_setor(:p_nome, :p_caixa, :p_aberto)", nativeQuery = true)
        void criarSetor(@Param("p_nome") String nome,
                        @Param("p_caixa") java.math.BigDecimal caixa,
                        @Param("p_aberto") Boolean aberto);

        @Transactional
        @Modifying
        @Query(value = "CALL pr_abrir_setor(:p_setor_id)", nativeQuery = true)
        void abrirSetor(@Param("p_setor_id") Long setorId);

        @Transactional
        @Modifying
        @Query(value = "CALL pr_fechar_setor(:p_setor_id)", nativeQuery = true)
        void fecharSetor(@Param("p_setor_id") Long setorId);

        @Transactional
        @Modifying
        @Query(value = "CALL pr_update_setor(:p_setor_id, :p_nome, :p_caixa, :p_aberto)", nativeQuery = true)
        void atualizarSetor(
                        @Param("p_setor_id") Long setorId,
                        @Param("p_nome") String nome,
                        @Param("p_caixa") java.math.BigDecimal caixa,
                        @Param("p_aberto") Boolean aberto);
}
