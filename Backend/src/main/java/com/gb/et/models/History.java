package com.gb.et.models;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.gb.et.data.HistoryTypeEnum;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
public class History {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    String message;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "dd-MM-yyyy hh:mm:ss a", timezone = "Asia/Kolkata")
    Date creationDate;

    @Enumerated(EnumType.STRING)
    HistoryTypeEnum historyType;

    Long foreignKey;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "organization_id")
    @JsonIgnore
    Organization organization;

    public History(Transaction transaction, String... type) {
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy");
        this.historyType = HistoryTypeEnum.TRANSACTION;
        this.organization = transaction.getOrganization();
        if (type.length > 0) {
            this.message = "Transaction deleted for " + dateFormat.format(transaction.getDate()) + " for " + transaction.getParty();
            this.foreignKey = null;
        } else {
            this.message = "Transaction added/updated for " + dateFormat.format(transaction.getDate()) + " for " + transaction.getParty();
            this.foreignKey = transaction.getId();
        }
    }

    public History(FileEntityForVault file) {
        this.message = "New file uploaded - " + file.getFilename();
        this.historyType = HistoryTypeEnum.FILE;
        this.foreignKey = file.getId();
        this.organization = file.getOrganization();
    }

    @PrePersist
    protected void onCreate() {
        creationDate = new Date();
    }
}
