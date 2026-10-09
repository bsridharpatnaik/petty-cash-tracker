package com.gb.et.service;

import com.gb.et.data.FileInfo;
import com.gb.et.data.TransactionCreateDTO;
import com.gb.et.models.FileEntity;
import com.gb.et.repository.FileRepository;
import com.gb.et.security.services.UserDetailsServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class TransactionValidationService {

    @Autowired
    UserDetailsServiceImpl userDetailsService;

    @Autowired
    FileRepository fileRepository;

    public void validateTransactionCreateDTO(TransactionCreateDTO dto) throws Exception {
        if (dto == null) {
            throw new Exception("TransactionCreateDTO must not be null");
        }

        if (dto.getTransactionType() == null) {
            throw new Exception("TransactionCreate Type must not be null");
        }

        if (dto.getDate() == null) {
            throw new Exception("Date must not be null");
        }

        if (dto.getTitle() == null || dto.getTitle().isEmpty()) {
            throw new Exception("Title must not be null or empty");
        }

        if (dto.getParty() == null || dto.getParty().isEmpty()) {
            throw new Exception("Party must not be null or empty");
        }

        if (dto.getAmount() == null) {
            throw new Exception("Amount must not be null");

        }
    }
}
