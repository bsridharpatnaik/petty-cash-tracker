package com.gb.et.service;

import com.gb.et.data.FileInfo;
import com.gb.et.models.DocumentVault;
import com.gb.et.models.Organization;
import org.springframework.stereotype.Service;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class VaultService {

    public DocumentVault createMockDocumentVault() throws ParseException {
        // Create organization
        Organization organization = new Organization();
        organization.setId(100L);
        organization.setName("Global Tech Solutions");

        // Create file list
        List<FileInfo> files = new ArrayList<>();
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy");

        // Add 20 FileInfo instances
        files.add(new FileInfo(UUID.fromString("123e4567-e89b-12d3-a456-426614174000"), "report-2024-01-01.pdf", dateFormat.parse("01-01-2024")));
        files.add(new FileInfo(UUID.fromString("123e4567-e89b-12d3-a456-426614174001"), "invoice-2024-01-02.pdf", dateFormat.parse("02-01-2024")));
        // Repeat adding files as needed with unique UUIDs and filenames

        // Complete list with 20 FileInfo instances
        String[] filenames = {"contract-2024-01-03.pdf", "summary-2024-01-04.pdf", "budget-2024-01-05.pdf",
                "meeting-notes-2024-01-06.pdf", "proposal-2024-01-07.pdf", "email-correspondence-2024-01-08.pdf",
                "project-plan-2024-01-09.pdf", "compliance-documents-2024-01-10.pdf", "sales-report-2024-01-11.pdf",
                "customer-feedback-2024-01-12.pdf", "audit-report-2024-01-13.pdf", "training-material-2024-01-14.pdf",
                "annual-review-2024-01-15.pdf", "financial-statement-2024-01-16.pdf", "risk-assessment-2024-01-17.pdf",
                "policy-document-2024-01-18.pdf", "strategic-plan-2024-01-19.pdf", "service-agreement-2024-01-20.pdf"};

        for (int i = 3; i < 20; i++) {
            files.add(new FileInfo(UUID.randomUUID(), filenames[i - 3], dateFormat.parse(String.format("0%d-01-2024", i + 1))));
        }

        // Create DocumentVault
        DocumentVault vault = new DocumentVault();
        vault.setVaultId(1L);
        vault.setFiles(files);
        vault.setOrganization(organization);
        return vault;
    }
}
