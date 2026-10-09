package com.gb.et.models;


import com.fasterxml.jackson.annotation.JsonIgnore;
import com.gb.et.data.FileInfo;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Entity
@Data
@NoArgsConstructor
public class DocumentVault {

    @Id
    Long vaultId;

    @ElementCollection
    @CollectionTable(name = "transaction_files", joinColumns = @JoinColumn(name = "transaction_id"))
    @Column(name = "file_info")
    private List<FileInfo> files = new ArrayList<>();

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "organization_id")
    @JsonIgnore
    private Organization organization;
}
