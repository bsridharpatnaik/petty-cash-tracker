package com.gb.et.data;

import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.gb.et.models.Transaction;
import com.gb.et.models.TransactionType;
import com.gb.et.others.DoubleTwoDigitDecimalSerializer;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class TransactionSummary {
    private Map<TransactionType, List<TransactionDTO>> transactionsByType;
    @JsonSerialize(using = DoubleTwoDigitDecimalSerializer.class)
    private Double carryForward;
    @JsonSerialize(using = DoubleTwoDigitDecimalSerializer.class)
    private Double totalIncome;
    @JsonSerialize(using = DoubleTwoDigitDecimalSerializer.class)
    private Double totalExpense;
    @JsonSerialize(using = DoubleTwoDigitDecimalSerializer.class)
    private Double balance;
    private String username;

    // Constructors, Getters, and Setters
    public TransactionSummary(Map<TransactionType, List<TransactionDTO>> transactionsByType,
                              Double carryForward, Double totalIncome, Double totalExpense,
                              Double balance, String username) {
        this.transactionsByType = transactionsByType;
        this.carryForward = carryForward;
        this.totalIncome = totalIncome;
        this.totalExpense = totalExpense;
        this.balance = balance;
        this.username = username;
    }
}
