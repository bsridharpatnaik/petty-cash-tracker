package com.gb.et.models;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.gb.et.data.FileInfo;
import com.gb.et.others.DoubleTwoDigitDecimalSerializer;
import javax.persistence.*;

import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.envers.Audited;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.UUID;

@Entity
@Data
@NoArgsConstructor
@Audited
public class Transaction {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    @JsonInclude
    private Long id;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "dd-MM-yyyy", timezone = "Asia/Kolkata")
    private Date date;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "dd-MM-yyyy hh:mm:ss a", timezone = "Asia/Kolkata")
    private Date creationDate;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "dd-MM-yyyy hh:mm:ss a", timezone = "Asia/Kolkata")
    private Date modificationDate;

    private String title;
    private String party;
    private String Description;

    @JsonSerialize(using = DoubleTwoDigitDecimalSerializer.class)
    private Double amount;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "organization_id")
    @JsonIgnore
    private Organization organization;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "transaction_file_mapping", joinColumns = @JoinColumn(name = "transaction_id"))
    @Column(name = "file_uuid")
    private List<UUID> fileUuids = new ArrayList<>();

    @Enumerated(EnumType.STRING)
    private TransactionType transactionType;
}
