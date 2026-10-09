// NoteRepository.java
package com.gb.et.repository;

import com.gb.et.models.Note;
import com.gb.et.models.Organization;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Date;
import java.util.List;

@Repository
public interface NoteRepository extends JpaRepository<Note, Long> {
    @Query("SELECT n FROM Note n WHERE DATE(n.date) = DATE(:date) AND n.organization = :organization ORDER BY n.id DESC")
    List<Note> findByDateAndOrganizationOrderByIdDesc(@Param("date") Date date, @Param("organization") Organization organization);
}