package com.gb.et.repository;

import com.gb.et.models.Organization;
import com.gb.et.models.Transaction;
import com.gb.et.models.TransactionType;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Date;
import java.util.List;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {

    @Query("SELECT t FROM Transaction t WHERE FUNCTION('MONTH', t.date) = FUNCTION('MONTH', :date) " +
            "AND FUNCTION('YEAR', t.date) = FUNCTION('YEAR', :date) " +
            "AND t.transactionType = :type AND t.organization = :organization " +
            "AND (:party IS NULL OR :party = '' OR t.party = :party) " +
            "ORDER BY t.creationDate DESC")
    List<Transaction> findByMonthAndTransactionTypeAndOrganizationAndParty(
            @Param("date") Date date,
            @Param("type") TransactionType type,
            @Param("organization") Organization organization,
            @Param("party") String party,
            Sort sort);


    // Update findByDateAndTransactionTypeAndOrganization to include party filter
    @Query("SELECT t FROM Transaction t WHERE FUNCTION('DATE', t.date) = FUNCTION('DATE', :date) " +
            "AND t.transactionType = :type AND t.organization = :organization " +
            "AND (:party IS NULL OR :party = '' OR t.party = :party)")
    List<Transaction> findByDateAndTransactionTypeAndOrganization(
            @Param("date") Date date,
            @Param("type") TransactionType type,
            @Param("organization") Organization organization,
            @Param("party") String party,
            Sort sort);

    // Update findByMonthAndTransactionTypeAndOrganization to include party filter
    @Query("SELECT t FROM Transaction t WHERE FUNCTION('MONTH', t.date) = FUNCTION('MONTH', :date) " +
            "AND FUNCTION('YEAR', t.date) = FUNCTION('YEAR', :date) AND t.transactionType = :type " +
            "AND t.organization = :organization " +
            "AND (:party IS NULL OR :party = '' OR t.party = :party)")
    List<Transaction> findByMonthAndTransactionTypeAndOrganization(
            @Param("date") Date date,
            @Param("type") TransactionType type,
            @Param("organization") Organization organization,
            @Param("party") String party,
            Sort sort);

    // Update findByDateRangeAndOrganization to include party filter
    @Query("SELECT t FROM Transaction t WHERE t.date BETWEEN :startDate AND :endDate " +
            "AND t.organization = :organization " +
            "AND (:party IS NULL OR :party = '' OR t.party = :party) ORDER BY t.date ASC")
    List<Transaction> findByDateRangeAndOrganization(
            @Param("startDate") Date startDate,
            @Param("endDate") Date endDate,
            @Param("organization") Organization organization,
            @Param("party") String party);

    // Update sumAmountByTypeBeforeDateAndOrganization to include party filter
    @Query("SELECT t.transactionType, SUM(t.amount) FROM Transaction t WHERE t.date < :date " +
            "AND t.organization = :organization " +
            "AND (:party IS NULL OR :party = '' OR t.party = :party) GROUP BY t.transactionType")
    List<Object[]> sumAmountByTypeBeforeDateAndOrganization(
            @Param("date") Date date,
            @Param("organization") Organization organization,
            @Param("party") String party);

    // Existing method for finding distinct parties - no changes required
    @Query("SELECT DISTINCT t.party FROM Transaction t WHERE t.organization = :organization")
    List<String> findDistinctPartiesByOrganization(@Param("organization") Organization organization);

    @Query("SELECT t FROM Transaction t WHERE t.date BETWEEN :startDate AND :endDate AND t.organization = :organization " +
            "AND (:party IS NULL OR :party = '' OR t.party = :party) ORDER BY t.date ASC")
    List<Transaction> findByDateRangeAndOrganizationAndParty(
            @Param("startDate") Date startDate,
            @Param("endDate") Date endDate,
            @Param("organization") Organization organization,
            @Param("party") String party);

    @Query("SELECT t FROM Transaction t WHERE FUNCTION('DATE', t.date) = FUNCTION('DATE', :date) " +
            "AND t.transactionType = :type AND t.organization = :organization " +
            "AND (:party IS NULL OR :party = '' OR t.party = :party) " +
            "ORDER BY t.creationDate DESC")
    List<Transaction> findByDateAndTransactionTypeAndOrganizationAndParty(
            @Param("date") Date date,
            @Param("type") TransactionType type,
            @Param("organization") Organization organization,
            @Param("party") String party,
            Sort sort);

    @Query("SELECT t.transactionType, SUM(t.amount) FROM Transaction t " +
            "WHERE t.date < :date AND t.organization = :organization " +
            "AND (:party IS NULL OR :party = '' OR t.party = :party) " +
            "GROUP BY t.transactionType")
    List<Object[]> sumAmountByTypeBeforeDateAndOrganizationAndParty(
            @Param("date") Date date,
            @Param("organization") Organization organization,
            @Param("party") String party);

}



