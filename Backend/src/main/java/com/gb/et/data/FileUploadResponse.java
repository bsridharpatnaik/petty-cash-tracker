package com.gb.et.data;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.gb.et.others.DoubleTwoDigitDecimalSerializer;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Date;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class FileUploadResponse {
    private String filename;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "dd-MM-yyyy")
    private Date uploadDate;
    private Long folderId;
    private Long id;
    @JsonSerialize(using = DoubleTwoDigitDecimalSerializer.class)
    private double sizeMB;
}

