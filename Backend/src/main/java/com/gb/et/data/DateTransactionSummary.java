package com.gb.et.data;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.gb.et.models.Transaction;
import lombok.Data;

import java.util.Date;
import java.util.List;

@Data
public class DateTransactionSummary {

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "dd-MM-yyyy", timezone = "Asia/Kolkata")
    private Date date;
    private double carryForward;
    private double totalIncome;
    private double totalExpense;
    List<TransactionDTO> incomeTransactions;
    List<TransactionDTO> expenseTransactions;
    private double balance;

    // Constructor, Getters and Setters
    public DateTransactionSummary(Date date, double carryForward, double totalIncome, double totalExpense,
                                  List<TransactionDTO> incomeTransactions, List<TransactionDTO> expenseTransactions, double balance) {
        this.date = date;
        this.carryForward = carryForward;
        this.totalIncome = totalIncome;
        this.totalExpense = totalExpense;
        this.incomeTransactions = incomeTransactions;
        this.expenseTransactions = expenseTransactions;
        this.balance = balance;
    }
}
