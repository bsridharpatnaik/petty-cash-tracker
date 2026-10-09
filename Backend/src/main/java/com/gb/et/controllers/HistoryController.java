package com.gb.et.controllers;

import com.gb.et.models.History;
import com.gb.et.repository.HistoryRepo;
import com.gb.et.service.HistoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/history")
public class HistoryController {

    @Autowired
    HistoryService historyService;

    @GetMapping
    public List<History> getHistory(){
            return historyService.getHistory();
    }
}
