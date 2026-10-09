package com.gb.et.data;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.gb.et.others.DoubleTwoDigitDecimalSerializer;
import lombok.Data;

import java.util.Date;
import java.util.List;
import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonProperty;

public class FolderContentsResponse {
    private Long id;
    private String name;
    private Long parentFolderId;
    private List<FolderSummary> subFolders;
    private List<FileSummary> files;
    private List<FolderPathDto> breadcrumb;
    private String username;

    // Constructor
    public FolderContentsResponse(Long id, String name, Long parentFolderId,
                                  List<FolderSummary> subFolders, List<FileSummary> files, List<FolderPathDto> breadcrumb, String username) {
        this.id = id;
        this.name = name;
        this.parentFolderId = parentFolderId;
        this.subFolders = subFolders;
        this.files = files;
        this.breadcrumb = breadcrumb;
        this.username = username;
    }

    // Getters and Setters


    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public List<FolderPathDto> getBreadcrumb() {
        return breadcrumb;
    }

    public void setBreadcrumb(List<FolderPathDto> breadcrumb) {
        this.breadcrumb = breadcrumb;
    }

    @JsonProperty
    public Long getId() {
        return id;
    }

    @JsonProperty
    public String getName() {
        return name;
    }

    @JsonProperty
    public Long getParentFolderId() {
        return parentFolderId;
    }

    @JsonProperty
    public List<FolderSummary> getSubFolders() {
        return subFolders;
    }

    @JsonProperty
    public List<FileSummary> getFiles() {
        return files;
    }

    public static class FolderSummary {
        private Long id;
        private String name;
        private int itemCount;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "dd-MM-yyyy")
        private Date lastUpdateDate;

        // Constructor
        public FolderSummary(Long id, String name, int itemCount, Date lastUpdateDate) {
            this.id = id;
            this.name = name;
            this.itemCount = itemCount;
            this.lastUpdateDate = lastUpdateDate;
        }

        // Getters and Setters


        public Date getLastUpdateDate() {
            return lastUpdateDate;
        }

        public void setLastUpdateDate(Date lastUpdateDate) {
            this.lastUpdateDate = lastUpdateDate;
        }

        public int getItemCount() {
            return itemCount;
        }

        public void setItemCount(int itemCount) {
            this.itemCount = itemCount;
        }

        @JsonProperty
        public Long getId() {
            return id;
        }

        @JsonProperty
        public String getName() {
            return name;
        }
    }

    public static class FileSummary {
        private Long id;
        private String filename;
        @JsonSerialize(using = DoubleTwoDigitDecimalSerializer.class)
        private double sizeMB;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "dd-MM-yyyy")
        Date lastUpdateDate;


        // Constructor
        public FileSummary(Long id, String filename, double sizeMB, Date lastUpdateDate) {
            this.id = id;
            this.filename = filename;
            this.sizeMB = sizeMB;
            this.lastUpdateDate = lastUpdateDate;
        }

        // Getters and Setters

        public Date getLastUpdateDate() {
            return lastUpdateDate;
        }

        public void setLastUpdateDate(Date lastUpdateDate) {
            this.lastUpdateDate = lastUpdateDate;
        }

        public double getSizeMB() {
            return sizeMB;
        }

        public void setSizeMB(double sizeMB) {
            this.sizeMB = sizeMB;
        }

        @JsonProperty
        public Long getId() {
            return id;
        }

        @JsonProperty
        public String getFilename() {
            return filename;
        }
    }
}
