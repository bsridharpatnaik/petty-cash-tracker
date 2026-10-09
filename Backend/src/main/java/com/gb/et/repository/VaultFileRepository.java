package com.gb.et.repository;

import com.gb.et.models.FileEntityForVault;
import com.gb.et.models.FolderEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface VaultFileRepository extends JpaRepository<FileEntityForVault, Long> {
    //Optional<FileEntityForVault> findByFileUuid(String fileUuid);
    boolean existsByFilenameAndFolder(String filename, FolderEntity folder);
}
