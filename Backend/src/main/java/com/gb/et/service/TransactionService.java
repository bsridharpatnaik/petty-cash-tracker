package com.gb.et.service;

import com.gb.et.data.FileInfo;
import com.gb.et.data.HistoryTypeEnum;
import com.gb.et.data.TransactionCreateDTO;
import com.gb.et.models.FileEntity;
import com.gb.et.models.History;
import com.gb.et.models.Organization;
import com.gb.et.models.Transaction;
import com.gb.et.repository.FileRepository;
import com.gb.et.repository.HistoryRepo;
import com.gb.et.repository.TransactionRepository;
import com.gb.et.security.services.UserDetailsServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.PostMapping;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class TransactionService {

    @Autowired
    TransactionRepository transactionRepository;

    @Autowired
    private TransactionValidationService validationService;

    @Autowired
    UserDetailsServiceImpl userDetailsService;

    @Autowired
    FileRepository fileRepository;

    @Autowired
    HistoryRepo historyRepository;

    @Transactional
    public Transaction createTransaction(TransactionCreateDTO payload) throws Exception {
        validationService.validateTransactionCreateDTO(payload);
        Transaction transaction = new Transaction();
        setFields(payload, transaction);
        transactionRepository.save(transaction);
        historyRepository.save(new History(transaction));
        return transaction;
    }

    private void setFields(TransactionCreateDTO payload, Transaction transaction) throws Exception {
        transaction.setAmount(payload.getAmount());
        transaction.setDate(payload.getDate());
        transaction.setParty(payload.getParty());
        transaction.setTitle(payload.getTitle());
        transaction.setDescription(payload.getDescription());
        transaction.setOrganization(userDetailsService.getOrganizationForCurrentUser());
        transaction.setFileUuids(getUUIDListFromFileInfo(payload.getFiles()));
        transaction.setTransactionType(payload.getTransactionType());
        transaction.setCreationDate(new Date());
        transaction.setModificationDate(new Date());
    }


    @Transactional
    public Transaction updateTransaction(Long id, TransactionCreateDTO payload) throws Exception {
        // Fetch the existing transaction from the database
        Transaction existingTransaction = transactionRepository.findById(id)
                .orElseThrow(() -> new Exception("Transaction not found with id: " + id));

        // Update fields based on the payload
        if (payload.getDate() != null) {
            existingTransaction.setDate(payload.getDate());
        }
        if (payload.getTitle() != null) {
            existingTransaction.setTitle(payload.getTitle());
        }
        if (payload.getDescription() != null) {
            existingTransaction.setDescription(payload.getDescription());
        }
        if (payload.getParty() != null) {
            existingTransaction.setParty(payload.getParty());
        }
        if (payload.getAmount() != null) {
            existingTransaction.setAmount(payload.getAmount());
        }
        if (payload.getFiles() != null) {
            List<UUID> uuidList = getUUIDListFromFileInfo(payload.getFiles());
            existingTransaction.setFileUuids(uuidList);
        }
        if (payload.getTransactionType() != null) {
            existingTransaction.setTransactionType(payload.getTransactionType());
        }
        existingTransaction.setModificationDate(new Date());
        transactionRepository.save(existingTransaction);
        historyRepository.save(new History(existingTransaction));
        return existingTransaction;
    }

    private List<UUID> getUUIDListFromFileInfo(List<FileInfo> fileList) throws Exception {

        if (fileList == null || fileList.isEmpty()) {
            return new ArrayList<>();
        }

        // Extract UUID strings from FileInfo
        List<String> uuidStrings = fileList.stream()
                .filter(Objects::nonNull)
                .map(fileInfo -> fileInfo.getFileUuid().toString())
                .collect(Collectors.toList());

        // Fetch all files in batch
        List<FileEntity> files = fileRepository.findByFileUuidIn(uuidStrings);

        if (files == null || files.isEmpty()) {
            throw new Exception("Files not found!");
        }

        Organization currentOrg = userDetailsService.getOrganizationForCurrentUser();

        List<UUID> uuidList = new ArrayList<>();

        for (FileEntity fileEntity : files) {

            if (fileEntity == null)
                continue;

            if (!fileEntity.getOrganization().equals(currentOrg))
                throw new Exception("User not allowed to access file: " + fileEntity.getFileUuid());

            uuidList.add(UUID.fromString(fileEntity.getFileUuid()));
        }

        return uuidList;
    }


    public List<String> getParty() {
        return transactionRepository.findDistinctPartiesByOrganization(userDetailsService.getOrganizationForCurrentUser());
    }

    @Transactional
    public void deleteTransaction(Long id) throws Exception {
        Transaction existingTransaction = transactionRepository.findById(id)
                .orElseThrow(() -> new Exception("Transaction not found with id: " + id));

        historyRepository.save(new History(existingTransaction, "Deleted"));
        transactionRepository.deleteById(id);
    }
}
