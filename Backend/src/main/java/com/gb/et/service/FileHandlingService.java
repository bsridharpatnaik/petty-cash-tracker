package com.gb.et.service;

import com.gb.et.data.FileDownloadInfo;
import com.gb.et.data.FileInfo;
import com.gb.et.models.FileEntity;
import com.gb.et.models.History;
import com.gb.et.repository.FileRepository;
import com.gb.et.repository.HistoryRepo;
import com.gb.et.security.services.UserDetailsServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Date;
import java.util.List;
import java.util.UUID;

@Service
public class FileHandlingService {

    @Autowired
    private FileRepository fileRepository;

    @Autowired
    UserDetailsServiceImpl userDetailsService;

    @Autowired
    HistoryRepo historyRepo;

    @Transactional
    public FileInfo uploadFile(MultipartFile file) throws IOException {
        String filename = file.getOriginalFilename();
        byte[] data = file.getBytes();
        UUID fileUuid = UUID.randomUUID();
        FileEntity fileEntity = new FileEntity();
        fileEntity.setFileUuid(fileUuid.toString());
        fileEntity.setFilename(filename);
        fileEntity.setData(data);
        fileEntity.setOrganization(userDetailsService.getOrganizationForCurrentUser());
        fileEntity.setUploadDate(new Date());
        fileRepository.save(fileEntity);
        return new FileInfo(fileEntity);
    }

    public FileDownloadInfo downloadFile(String fileUuid) throws IOException {
        FileEntity fileEntity = fileRepository.findByFileUuid(fileUuid);
        if (fileEntity == null) {
            throw new IOException("File not found");
        }

        if (!userDetailsService.getOrganizationForCurrentUser().equals(fileEntity.getOrganization()))
            throw new IOException("User not allowed to download file");

        return new FileDownloadInfo(fileEntity.getFilename(), fileEntity.getData());
    }
}