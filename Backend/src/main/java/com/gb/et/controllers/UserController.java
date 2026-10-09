package com.gb.et.controllers;

import com.gb.et.data.FileStorageException;
import com.gb.et.data.FileUploadResponse;
import com.gb.et.data.FolderContentsResponse;
import com.gb.et.models.FileEntityForVault;
import com.gb.et.models.FolderEntity;
import com.gb.et.service.FolderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@RestController
@RequestMapping("/user")
public class UserController {

    @GetMapping("/status")
    public ResponseEntity<String> getFolderContents(@RequestParam(required = false) Long folderId) {
        return ResponseEntity.ok("true");
    }
}
