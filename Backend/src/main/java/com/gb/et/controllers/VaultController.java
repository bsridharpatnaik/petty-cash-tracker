package com.gb.et.controllers;

import com.gb.et.data.*;
import com.gb.et.models.FileEntityForVault;
import com.gb.et.models.FolderEntity;
import com.gb.et.service.FolderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@RestController
@RequestMapping("/api/vault")
public class VaultController {

    @Autowired
    private FolderService folderService;

    // Create a folder
    @PostMapping("/folders")
    public ResponseEntity<FolderEntity> createFolder(@RequestParam String name, @RequestParam(required = false) Long parentId) {
        FolderEntity folder = folderService.createFolder(name, parentId);
        return ResponseEntity.ok(folder);
    }

    // Upload a file
    @PostMapping("/files")
    public ResponseEntity<FileUploadResponse> uploadFile(@RequestParam("file") MultipartFile file, @RequestParam Long folderId) {
        try {
            return ResponseEntity.ok(folderService.uploadFile(file.getOriginalFilename(), file.getBytes(), folderId));
        } catch (IOException ex) {
            throw new FileStorageException("Failed to upload file: " + ex.getMessage());
        }
    }

    // Get folder contents (simplified response)
    @GetMapping("/folders")
    public ResponseEntity<FolderContentsResponse> getFolderContents(@RequestParam(required = false) Long folderId) {
        FolderContentsResponse folderContents = folderService.getFolderContentsWithSummary(folderId);
        return ResponseEntity.ok(folderContents);
    }

    // Download file
    @GetMapping("/files/download/{id}")
    public ResponseEntity<byte[]> downloadFile(@PathVariable Long id) {
        FileEntityForVault file = folderService.getFileById(id);

        return ResponseEntity.ok()
                .header("Content-Disposition", "attachment; filename=\"" + file.getFilename() + "\"")
                .header("Content-Type", "application/octet-stream")
                .body(file.getData());
    }

    @DeleteMapping("/files/{id}")
    public ResponseEntity<Void> deleteFile(@PathVariable Long id) {
        folderService.deleteFile(id);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/folders/{folderId}")
    public ResponseEntity<Void> deleteFolder(@PathVariable Long folderId) {
        folderService.deleteFolder(folderId);
        return ResponseEntity.noContent().build();
    }
}
