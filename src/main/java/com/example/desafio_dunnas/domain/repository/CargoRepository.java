package com.example.desafio_dunnas.domain.repository;

import com.example.desafio_dunnas.domain.entity.Cargo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CargoRepository extends JpaRepository<Cargo, Long> {

}
