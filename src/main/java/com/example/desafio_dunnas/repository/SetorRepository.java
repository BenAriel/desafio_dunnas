package com.example.desafio_dunnas.repository;

import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.example.desafio_dunnas.model.Setor;

@Repository
public interface SetorRepository extends JpaRepository<Setor, Long> {

        // Consultas que consideram soft delete (apenas setores não excluídos)

        @Query("SELECT s FROM Setor s WHERE s.aberto = true AND s.deletedAt IS NULL ORDER BY s.nome")
        List<Setor> findByAbertoTrue();

        @Query("SELECT s FROM Setor s WHERE s.aberto = true AND s.deletedAt IS NULL ORDER BY s.nome")
        Page<Setor> findByAbertoTrue(Pageable pageable);

        @Query("SELECT s FROM Setor s WHERE s.id NOT IN (SELECT r.setor.id FROM Recepcionista r WHERE r.setor IS NOT NULL) AND s.deletedAt IS NULL ORDER BY s.nome")
        List<Setor> findSetoresSemRecepcionista();

        // Consultas que incluem setores soft deleted (para administração)
        @Query("SELECT s FROM Setor s WHERE s.deletedAt IS NULL ORDER BY s.nome")
        Page<Setor> findAllNaoExcluidos(Pageable pageable);

        @Query("SELECT s FROM Setor s WHERE s.deletedAt IS NOT NULL ORDER BY s.deletedAt DESC")
        Page<Setor> findAllExcluidos(Pageable pageable);

        /**
         * Procedure: cria setor.
         *
         * @pre Parâmetros validados no service
         * @post Setor criado; rollback em caso de erro
         * @throws DataIntegrityViolationException em caso de violação de integridade no
         *                                         banco
         * @throws DataAccessException             para outros erros de acesso a dados
         */
        @Transactional
        @Modifying
        @Query(value = "CALL pr_create_setor(:p_nome, :p_caixa, :p_aberto)", nativeQuery = true)
        void criarSetor(@Param("p_nome") String nome,
                        @Param("p_caixa") java.math.BigDecimal caixa,
                        @Param("p_aberto") Boolean aberto);

        /**
         * Procedure: marca setor como aberto.
         *
         * @post Setor fica disponível para agendamentos; rollback em caso de erro
         * @throws DataAccessException para erros de acesso a dados
         */
        @Transactional
        @Modifying
        @Query(value = "CALL pr_abrir_setor(:p_setor_id)", nativeQuery = true)
        void abrirSetor(@Param("p_setor_id") Long setorId);

        /**
         * Procedure: marca setor como fechado.
         *
         * @post Setor deixa de aceitar agendamentos; rollback em caso de erro
         * @throws DataAccessException para erros de acesso a dados
         */
        @Transactional
        @Modifying
        @Query(value = "CALL pr_fechar_setor(:p_setor_id)", nativeQuery = true)
        void fecharSetor(@Param("p_setor_id") Long setorId);

        /**
         * Procedure: atualiza dados básicos do setor.
         *
         * @post Nome/caixa/status atualizados; rollback em caso de erro
         * @throws DataIntegrityViolationException em caso de violação de integridade no
         *                                         banco
         * @throws DataAccessException             para outros erros de acesso a dados
         */
        @Transactional
        @Modifying
        @Query(value = "CALL pr_update_setor(:p_setor_id, :p_nome, :p_caixa, :p_aberto)", nativeQuery = true)
        void atualizarSetor(
                        @Param("p_setor_id") Long setorId,
                        @Param("p_nome") String nome,
                        @Param("p_caixa") java.math.BigDecimal caixa,
                        @Param("p_aberto") Boolean aberto);

        /**
         * Procedure: soft delete de setor com auditoria.
         *
         * @post Marca como excluído logicamente e registra auditoria; rollback em caso
         *       de erro
         * @throws DataAccessException para erros de acesso a dados
         */
        @Transactional
        @Modifying
        @Query(value = "CALL pr_soft_delete_setor(:p_setor_id, :p_deleted_by)", nativeQuery = true)
        void softDeleteSetor(@Param("p_setor_id") Long setorId, @Param("p_deleted_by") Long deletedBy);

        /**
         * Procedure: reativa setor previamente excluído.
         *
         * @post Remove marca de exclusão e registra auditoria; rollback em caso de erro
         * @throws DataAccessException para erros de acesso a dados
         */
        @Transactional
        @Modifying
        @Query(value = "CALL pr_reativar_setor(:p_setor_id, :p_reativado_by)", nativeQuery = true)
        void reativarSetor(@Param("p_setor_id") Long setorId, @Param("p_reativado_by") Long reativadoBy);

}
