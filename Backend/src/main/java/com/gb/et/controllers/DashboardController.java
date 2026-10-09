package com.gb.et.controllers;

import com.gb.et.data.DateTransactionSummary;
import com.gb.et.data.ErrorResponse;
import com.gb.et.data.MonthTransactionSummary;
import com.gb.et.data.TransactionSummary;
import com.gb.et.service.DashboardService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.text.ParseException;
import java.util.List;

@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    @Autowired
    private DashboardService dashboardService;

    // Modified to include 'party' parameter
    @GetMapping("/summary")
    public ResponseEntity<?> getTransactionSummary(@RequestParam String dateOrMonth,
                                                   @RequestParam(value = "party", required = false) String party) {
        try {
            TransactionSummary summary = dashboardService.getTransactionSummary(dateOrMonth, party);
            return ResponseEntity.ok(summary);
        } catch (ParseException e) {
            ErrorResponse errorResponse = new ErrorResponse(HttpStatus.BAD_REQUEST.value(), "Invalid date format: " + e.getMessage());
            return ResponseEntity.badRequest().body(errorResponse);
        } catch (Exception e) {
            ErrorResponse errorResponse = new ErrorResponse(HttpStatus.INTERNAL_SERVER_ERROR.value(), "Error retrieving data: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    // Modified to include 'party' parameter
    @GetMapping("/summary/grouped")
    public ResponseEntity<?> getTransactionSummaryGrouped(@RequestParam String startDate,
                                                          @RequestParam(required = false) String endDate,
                                                          @RequestParam(value = "party", required = false) String party) {
        try {
            MonthTransactionSummary summary = dashboardService.getTransactionsGroupedByDateRange(startDate, endDate, party);
            return ResponseEntity.ok(summary);
        } catch (ParseException e) {
            ErrorResponse errorResponse = new ErrorResponse(HttpStatus.BAD_REQUEST.value(), "Invalid date format: " + e.getMessage());
            return ResponseEntity.badRequest().body(errorResponse);
        } catch (Exception e) {
            ErrorResponse errorResponse = new ErrorResponse(HttpStatus.INTERNAL_SERVER_ERROR.value(), "Error retrieving data: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }
}


