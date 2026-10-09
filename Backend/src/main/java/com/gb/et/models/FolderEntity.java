package com.gb.et.models;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import lombok.Data;

import javax.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "folders")
@Data
public class FolderEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    private String name;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_folder_id")
    @JsonBackReference // Prevent infinite recursion for parentFolder
    private FolderEntity parentFolder;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "organization_id")
    @JsonIgnore
    private Organization organization;

    @OneToMany(mappedBy = "parentFolder", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference // Forward reference to subfolders
    private List<FolderEntity> subFolders = new ArrayList<>();

    @OneToMany(mappedBy = "folder", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference // Forward reference to files
    private List<FileEntityForVault> files = new ArrayList<>();

    // Method to generate the full folder path
    public String getFullPath() {
        StringBuilder fullPath = new StringBuilder();
        FolderEntity currentFolder = this;
        while (currentFolder != null) {
            fullPath.insert(0, "/" + currentFolder.getName());
            currentFolder = currentFolder.getParentFolder();
        }
        return fullPath.toString();
    }

    // Method to count items in a folder
    public int getItemCount() {
        int itemCount = files.size();  // Count files
        for (FolderEntity subFolder : subFolders) {
            itemCount += 1 + subFolder.getItemCount();  // Count subfolders and their items
        }
        return itemCount;
    }
}

