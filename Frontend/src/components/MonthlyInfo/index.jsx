import React from "react";
import "./index.css"; 

const MonthlyInfo = ({ val,handleToggle,handleDateChange }) => {
  const { date, carryForward, totalIncome, totalExpense, incomeTransactions, expenseTransactions, balance } = val;
  const [day, month, year] = date.split('-');
  const formattedDateForPicker = `${year}-${month}-${day}`;
   
  return (
    <div className="transaction-container" onClick={()=>{handleToggle("D");handleDateChange(formattedDateForPicker)}} >
    <div className="transaction-header">
      <span style={{fontSize:"12px",color: "#666875"}}>{date}</span>
      <span style={{fontSize:"12px",color: "#181D31"}}>C/F ₹{carryForward}</span>
    </div>
  
    <div className="transaction-grid">
      {/* Income Section */}
      <div className="transaction-income">
       <div style={{display:"flex",justifyContent:"space-between" ,alignItems:"center"}}>
       <h3 style={{fontSize:"10px", color:"#666875"}}>Income</h3>
       <h2 className="amount green"  style={{fontSize:"10px"}}>₹{totalIncome}</h2>
       </div>
        <div className="transaction-list">
          {incomeTransactions?.map((item, index) => (
            <div key={index} className="transaction-item">
           <div className="text_">
           <span style={{fontSize:"10px"}}>{item.title}</span>
           <span style={{fontSize:"10px",color:"#666875"}}>{item.party}</span>
            </div>
              <span className="amount green"  style={{fontSize:"10px"}}>₹{item.amount}</span>
            </div>
          ))}
        </div>
      </div>
  
      {/* Expense Section */}
      <div className="transaction-expense">
      <div style={{display:"flex",justifyContent:"space-between" ,alignItems:"center"}}>
        <h2 style={{fontSize:"10px" , color:"#666875"}}>Expenses</h2>
        <h2 className="amount red" style={{fontSize:"10px"}}>₹{totalExpense}</h2>
        </div>
        <div className="transaction-list">
          {expenseTransactions?.map((item, index) => (
            <div key={index} className="transaction-item">
                      <div className="text_">

                      <span style={{fontSize:"10px"}}>{item.title}</span>
                      <span style={{fontSize:"10px",color:"#666875"}}>{item.party}</span>
                      </div>
            

              <span className="amount red" style={{fontSize:"10px"}}>₹{item.amount}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  
    <div className="transaction-balance">
      <span style={{color:"#666875"}}>Balance &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</span>
      <span className="amount">₹{balance}</span>
    </div>
  </div>
  
  );
};

export default MonthlyInfo;
