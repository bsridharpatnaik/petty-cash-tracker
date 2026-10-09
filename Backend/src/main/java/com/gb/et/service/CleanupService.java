package com.gb.et.service;

import com.gb.et.repository.HistoryRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;

import java.util.Calendar;
import java.util.Date;
import com.gb.et.repository.*;
public class CleanupService {
    @Autowired
    private HistoryRepo historyRepository;

    @Autowired
    private RequestLogRepository requestLogRepository;

    @Scheduled(cron = "0 0 1 * * ?") // Runs every day at 1 AM
    public void cleanUpOldRequestLogs() {
        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.DAY_OF_YEAR, -10); // Go back 10 days
        Date cutoffDate = calendar.getTime();
        requestLogRepository.deleteByTimestampBefore(cutoffDate);
        System.out.println("Clean up of old request logs completed");
    }

    @Scheduled(cron = "0 0 0 * * ?") // Runs every day at midnight
    public void cleanUpOldHistoryEntries() {
        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.DAY_OF_YEAR, -10); // Go back 10 days
        Date cutoffDate = calendar.getTime();
        historyRepository.deleteByCreationDateBefore(cutoffDate);
        System.out.println("Clean up of old history logs completed");
    }
}
