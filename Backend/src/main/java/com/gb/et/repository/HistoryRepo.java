package com.gb.et.repository;

import com.gb.et.models.FolderEntity;
import com.gb.et.models.History;
import com.gb.et.models.Organization;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import org.springframework.transaction.annotation.Transactional;
import java.util.*;

@Repository
public interface HistoryRepo extends JpaRepository<History, Long> {
    List<History> findByOrganizationOrderByIdDesc(Organization organization);
    @Transactional
    void deleteByCreationDateBefore(Date cutoffDate);
}
