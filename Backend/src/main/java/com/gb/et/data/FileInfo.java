package com.gb.et.data;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.gb.et.models.FileEntity;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.Date;
import java.util.Objects;
import java.util.UUID;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class FileInfo implements Serializable {

    private UUID fileUuid;
    private String filename;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "dd-MM-yyyy")
    Date uploadDate;

    public FileInfo(FileEntity fileEntity) {
        this.fileUuid = UUID.fromString(fileEntity.getFileUuid());
        this.filename = fileEntity.getFilename();
        this.uploadDate = fileEntity.getUploadDate();
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        FileInfo fileInfo = (FileInfo) o;
        return Objects.equals(fileUuid, fileInfo.fileUuid) && Objects.equals(filename, fileInfo.filename);
    }

    @Override
    public int hashCode() {
        return Objects.hash(fileUuid, filename);
    }

    @Override
    public String toString() {
        return "FileInfo{" +
                "fileUuid=" + fileUuid +
                ", filename='" + filename + '\'' +
                '}';
    }
}
