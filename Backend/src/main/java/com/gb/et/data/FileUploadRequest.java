package com.gb.et.data;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

import javax.validation.constraints.NotNull;

@Data
public class FileUploadRequest {

    @NotNull
    private String filename;
    private Long folderId;

    @JsonIgnore
    @NotNull
    private MultipartFile file;
}
