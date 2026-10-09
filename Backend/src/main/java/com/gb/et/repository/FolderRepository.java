package com.gb.et.repository;

import com.gb.et.models.FolderEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface FolderRepository extends JpaRepository<FolderEntity, Long> {

    // Custom query to find the root folder
    @Query("SELECT f FROM FolderEntity f WHERE f.organization.id = :organizationId AND f.parentFolder IS NULL")
    Optional<FolderEntity> findRootFolderByOrganizationId(@Param("organizationId") Long organizationId);

    boolean existsByNameAndParentFolderId(String name, Long parentFolderId);

}
