import React, {  useState } from "react";
import { ReactComponent as IncomeIcon } from "../../assets/svgs/Download.svg";
import { ReactComponent as ExpenseIcon } from "../../assets/svgs/Upload.svg";
import Transaction from "../../components/Transaction";
import AddButton from "../AddButton";
import "./index.css";
import AddTransactionModal from "../TransactionalModal";
const TransactionInfo = ({
  transactionRef,
  totalIncome,
  totalExpense,
  carryForward,
  expense,
  income,
}) => {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [activeTab, setActiveTab] = useState("Expense");
  const [isUpdate, setIsUpdate] = useState(false);
  const [dataToShow, setdataToShow] = useState({});

  const handleTabClick = (tab) => {
    setActiveTab(tab);
  };

  const handleAddButtonClick = (item) => {
    setdataToShow(item);
    setIsModalOpen(true);
    setIsUpdate(false);
  };

  return (
    <div className="transaction-info">
      <div className="add-btn">
          <AddButton onClick={handleAddButtonClick} />
        </div>
      <div className="transaction-history">
        <h4>Transaction History</h4>
        <div className="tab-row" id="tab-row">
          <div
            className={`expense-tab ${
              activeTab === "Expense" ? "selected" : ""
            }`}
            onClick={() => handleTabClick("Expense")}
          >
            Expenses
          </div>
          <div
            className={`income-tab ${activeTab === "Income" ? "selected" : ""}`}
            onClick={() => handleTabClick("Income")}
          >
            Income
          </div>
        </div>
        {activeTab === "Expense" && expense.length === 0 && (
          <div className="no-transaction">No Transaction</div>
        )}
        {activeTab === "Income" && income.length === 0 && (
          <div className="no-transaction">No Transaction</div>
        )}
        <div classname="transaction_card" ref={transactionRef}>
        {activeTab === "Expense" &&
          expense.map((item, index) => {
            return (
              <Transaction
              transactionRe
                activeTab={activeTab}
                key={index}
                showIcon={true}
                showDetails={true}
                date={false}
                historyLog={false}
                item={item}
                handleAddButtonClick={handleAddButtonClick}
                setIsUpdate={setIsUpdate}
              />
            );
          })}
        {activeTab === "Income" &&
          income.map((item, index) => {
            return (
              <Transaction
                activeTab={activeTab}
                key={index}
                showIcon={true}
                showDetails={true}
                date={false}
                historyLog={false}
                item={item}
                handleAddButtonClick={handleAddButtonClick}
                setIsUpdate={setIsUpdate}
              />
            );
          })}
          </div>
      </div>
      <AddTransactionModal
        dataToShow={dataToShow}
        isOpen={isModalOpen}
        isUpdate={isUpdate}
        setIsModalOpen={setIsModalOpen}
      />
    </div>
  );
};

export default TransactionInfo;
