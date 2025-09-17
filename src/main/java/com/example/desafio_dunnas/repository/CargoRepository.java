package com.example.desafio_dunnas.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.desafio_dunnas.model.Cargo;

@Repository
public interface CargoRepository extends JpaRepository<Cargo, Long> {

}
