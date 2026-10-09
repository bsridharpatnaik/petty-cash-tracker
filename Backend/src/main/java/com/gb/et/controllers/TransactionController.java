package com.gb.et.controllers;

import com.gb.et.data.ErrorResponse;
import com.gb.et.data.TransactionCreateDTO;
import com.gb.et.models.Transaction;
import com.gb.et.service.TransactionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/transaction")
public class TransactionController {

    @Autowired
    TransactionService transactionService;

    @PostMapping
    public ResponseEntity<?> createTransaction(@RequestBody TransactionCreateDTO payload) {
        try {
            Transaction newTransaction = transactionService.createTransaction(payload);
            return new ResponseEntity<>(newTransaction, HttpStatus.CREATED);  // Return 201 status code
        } catch (Exception e) {
            ErrorResponse errorResponse = new ErrorResponse(HttpStatus.INTERNAL_SERVER_ERROR.value(), e.getMessage());
            return new ResponseEntity<>(errorResponse, HttpStatus.INTERNAL_SERVER_ERROR);  // Return 500 with error details
        }
    }

    @PutMapping("/{id}")
    public Transaction updateTransaction(
            @PathVariable Long id,  // Extract path variable from URL
            @RequestBody TransactionCreateDTO payload) throws Exception {  // Extract request body as DTO
        return transactionService.updateTransaction(id, payload);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTransaction(@PathVariable Long id) throws Exception {
        transactionService.deleteTransaction(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/party")
    public List<String> getExistingParty() throws Exception {
        return transactionService.getParty();
    }
}
