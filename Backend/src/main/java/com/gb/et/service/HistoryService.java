package com.gb.et.service;

import com.gb.et.models.History;
import com.gb.et.repository.HistoryRepo;
import com.gb.et.security.services.UserDetailsServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class HistoryService {

    @Autowired
    HistoryRepo historyRepo;

    @Autowired
    UserDetailsServiceImpl userDetailsService;

    public List<History> getHistory(){
        return historyRepo.findByOrganizationOrderByIdDesc(userDetailsService.getOrganizationForCurrentUser());
    }
}
