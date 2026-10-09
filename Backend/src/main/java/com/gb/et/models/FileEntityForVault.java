package com.gb.et.models;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;

import javax.persistence.*;
import java.util.Date;

@Entity
@Table(name = "vault_files")
@Data
public class FileEntityForVault {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    private String filename;

    @Lob
    @Column(name = "data")
    private byte[] data;

    private Date uploadDate;

    // Reference to the organization
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "organization_id")
    @JsonIgnore
    private Organization organization;

    // Reference to the folder where the file is located
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "folder_id")
    @JsonIgnore
    @JsonBackReference // Prevent infinite recursion for folder
    private FolderEntity folder;
}

