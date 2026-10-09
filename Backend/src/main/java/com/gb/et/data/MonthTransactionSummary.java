package com.gb.et.data;

import lombok.Data;

import java.util.List;

@Data
public class MonthTransactionSummary {
    private double carryForward;
    private double totalIncome;
    private double totalExpense;
    private double balance;
    private List<DateTransactionSummary> dailySummaries;

    public MonthTransactionSummary(double carryForward, double totalIncome, double totalExpense, double balance, List<DateTransactionSummary> dailySummaries) {
        this.carryForward = carryForward;
        this.totalIncome = totalIncome;
        this.totalExpense = totalExpense;
        this.balance = balance;
        this.dailySummaries = dailySummaries;
    }
}
