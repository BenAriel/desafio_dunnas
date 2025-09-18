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

import com.example.desafio_dunnas.model.Sala;

@Repository
public interface SalaRepository extends JpaRepository<Sala, Long> {

        // Consultas que consideram soft delete (apenas salas não excluídas)
        /**
         * Lista salas ativas de um setor específico, desconsiderando soft delete.
         *
         * @param setorId id do setor
         * @return lista de salas ativas do setor
         * @pre {@code setorId} não deve ser nulo
         * @post Operação apenas leitura
         */
        @Query("SELECT s FROM Sala s WHERE s.setor.id = :setorId AND s.ativa = true AND s.deletedAt IS NULL ORDER BY s.nome")
        List<Sala> findSalasAtivasPorSetor(@Param("setorId") Long setorId);

        @Query("SELECT s FROM Sala s WHERE s.setor.id = :setorId AND s.ativa = true AND s.setor.aberto = true AND s.deletedAt IS NULL ORDER BY s.nome")
        List<Sala> findSalasAtivasPorSetorAberto(@Param("setorId") Long setorId);

        @Query("SELECT s FROM Sala s WHERE s.setor.id = :setorId AND s.ativa = true AND s.setor.aberto = true AND s.deletedAt IS NULL ORDER BY s.nome")
        Page<Sala> findSalasAtivasPorSetorAberto(@Param("setorId") Long setorId, Pageable pageable);

        @Query("SELECT s FROM Sala s WHERE s.ativa = true AND s.deletedAt IS NULL ORDER BY s.setor.nome, s.nome")
        List<Sala> findAllSalasAtivas();

        @Query("SELECT s FROM Sala s WHERE s.ativa = true AND s.setor.aberto = true AND s.deletedAt IS NULL ORDER BY s.setor.nome, s.nome")
        List<Sala> findSalasAtivasDeSetoresAbertos();

        @Query("SELECT s FROM Sala s WHERE s.ativa = true AND s.setor.aberto = true AND s.deletedAt IS NULL ORDER BY s.setor.nome, s.nome")
        Page<Sala> findSalasAtivasDeSetoresAbertos(Pageable pageable);

        // Consultas que incluem salas soft deleted (para administração)

        @Query("SELECT s FROM Sala s WHERE s.deletedAt IS NULL ORDER BY s.setor.nome, s.nome")
        Page<Sala> findAllNaoExcluidas(Pageable pageable);

        @Query("SELECT s FROM Sala s WHERE s.deletedAt IS NULL AND s.setor.id = :setorId ORDER BY s.setor.nome, s.nome")
        Page<Sala> findAllNaoExcluidasBySetor(@Param("setorId") Long setorId, Pageable pageable);

        @Query("SELECT s FROM Sala s WHERE s.deletedAt IS NOT NULL ORDER BY s.deletedAt DESC")
        Page<Sala> findAllExcluidas(Pageable pageable);

        // Procedures para operações CRUD
        /**
         * Procedure: cria sala.
         *
         * @pre Parâmetros validados no service (nome, valor por hora, capacidade e
         *      setorId)
         * @post Sala criada com dados consistentes; rollback em caso de erro
         * @throws DataIntegrityViolationException em caso de violação de integridade no
         *                                         banco
         * @throws DataAccessException             para outros erros de acesso a dados
         */
        @Transactional
        @Modifying
        @Query(value = "CALL pr_create_sala(:p_nome, :p_valor_por_hora, :p_capacidade_maxima, :p_setor_id)", nativeQuery = true)
        void criarSala(
                        @Param("p_nome") String nome,
                        @Param("p_valor_por_hora") java.math.BigDecimal valorPorHora,
                        @Param("p_capacidade_maxima") Integer capacidadeMaxima,
                        @Param("p_setor_id") Long setorId);

        /**
         * Procedure: atualiza sala.
         *
         * @post Atualiza os campos informados; se {@code ativa} for falso, a sala
         *       não poderá ser usada em novos agendamentos; rollback em caso de erro
         * @throws DataIntegrityViolationException em caso de violação de integridade no
         *                                         banco
         * @throws DataAccessException             para outros erros de acesso a dados
         */
        @Transactional
        @Modifying
        @Query(value = "CALL pr_update_sala(:p_sala_id, :p_nome, :p_valor_por_hora, :p_capacidade_maxima, :p_ativa)", nativeQuery = true)
        void atualizarSala(
                        @Param("p_sala_id") Long id,
                        @Param("p_nome") String nome,
                        @Param("p_valor_por_hora") java.math.BigDecimal valorPorHora,
                        @Param("p_capacidade_maxima") Integer capacidadeMaxima,
                        @Param("p_ativa") Boolean ativa);

        /**
         * Procedure: soft delete de sala.
         *
         * @param salaId    Id da sala a excluir
         * @param deletedBy Id do usuário que realizou a exclusão
         * @post Marca a sala como excluída logicamente e registra auditoria; rollback
         *       em caso de erro
         * @throws DataIntegrityViolationException em caso de violação de integridade no
         *                                         banco
         * @throws DataAccessException             para outros erros de acesso a dados
         *                                         acesso a
         *                                         dados
         */
        @Transactional
        @Modifying
        @Query(value = "CALL pr_soft_delete_sala(:p_sala_id, :p_deleted_by)", nativeQuery = true)
        void softDeleteSala(@Param("p_sala_id") Long salaId, @Param("p_deleted_by") Long deletedBy);
}
