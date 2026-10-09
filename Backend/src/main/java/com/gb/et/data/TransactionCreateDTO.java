package com.gb.et.data;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.gb.et.models.TransactionType;
import com.gb.et.others.DoubleTwoDigitDecimalSerializer;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import lombok.Data;

import java.util.Date;
import java.util.List;

@Data
public class TransactionCreateDTO {
    private Long id;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "dd-MM-yyyy", timezone = "Asia/Kolkata")
    private Date date;
    private String title;
    private String description;
    private String party;
    @JsonSerialize(using = DoubleTwoDigitDecimalSerializer.class)
    private Double amount;
    List<FileInfo> files;
    TransactionType transactionType;
}
