package com.gb.et.data;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.gb.et.models.TransactionType;
import com.gb.et.others.DoubleTwoDigitDecimalSerializer;
import lombok.Data;

import java.util.Date;
import java.util.List;

@Data
public class TransactionDTO {

    private Long id;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "dd-MM-yyyy", timezone = "Asia/Kolkata")
    private Date date;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "dd-MM-yyyy hh:mm:ss a", timezone = "Asia/Kolkata")
    private Date creationDate;

    private String title;
    private String party;

    @JsonSerialize(using = DoubleTwoDigitDecimalSerializer.class)
    private Double amount;

    private TransactionType transactionType;

    private List<FileInfo> fileInfos;
}
