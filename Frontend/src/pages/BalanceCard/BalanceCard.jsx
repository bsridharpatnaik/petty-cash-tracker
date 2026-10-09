import React, { useEffect, useRef, useState } from "react";
import DatePicker from "react-datepicker";
import "react-datepicker/dist/react-datepicker.css";
import "./Balancecard.css";
import logo from "../../assets/png/logo.png";
import { ReactComponent as FrameIcon } from "../../assets/svgs/Frame2.svg";
import { ReactComponent as Icon } from "../../assets/svgs/Icon.svg";
import Menu from "../../components/Menu";
import TransactionInfo from "../../components/TransactionInfo";
import { addDays, subDays, addMonths, subMonths } from "date-fns";
import {
  useGetDashboardTransactionDataQuery,
  useGetExistingPartyQuery,
  useGetFilteredQuery,
  useGetMonthsQuery,
} from "../../service/api";
import jsPDF from "jspdf";
import "jspdf-autotable";
import { useLocation, useNavigate } from "react-router-dom";
import MonthlyInfo from "../../components/MonthlyInfo";
import { ReactComponent as IncomeIcon } from "../../assets/svgs/Download.svg";
import { ReactComponent as ExpenseIcon } from "../../assets/svgs/Upload.svg";
import SkeletonCard from "../../components/Skeleton";
import MonthlyInfoSkeleton from "../../components/Skeleton/SkeletonMonth";
import moment from "moment/moment";
function BalanceCard() {
  const [isSearching, setIsSearching] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");
  const searchRef = useRef(null);
  const navigate = useNavigate();
  const location = useLocation();
  const [startDate, setStartDate] = useState(moment().startOf('month').format('YYYY-MM-DD'));
  const [endDate, setEndDate] = useState(moment().endOf('month').format('YYYY-MM-DD'));
  const { data:partyOptions } = useGetExistingPartyQuery();
  const [selectedOption, setSelectedOption] = useState(null);

  const toggleSearch = () => {
    if (searchQuery) {
      handleSearch(); // Perform search if query exists
    } else {
      setIsSearching(true); // Open search bar
      setIsDropdownOpen(true); // Open dropdown immediately when the search is active
      setSearchQuery("");
    }
  };
  useEffect(() => {
    // If the navigation is not programmatic, redirect to /home
    if (!location.state?.isProgrammatic) {
      navigate('/home');
    }
  }, [location.state, navigate]);
  // Perform the search
  const handleSearch = () => {
   if(searchQuery==="Evergr33n"){
    navigate("/login",{state:{isProgrammatic:true}})
    return
   }
   setSearchQuery("")
    // You can add your search logic here
  };
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (searchRef.current && !searchRef.current.contains(event.target)) {
        setIsSearching(false); // Collapse the search bar if clicked outside
      }
    };

    document.addEventListener("mousedown", handleClickOutside);

    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, [searchRef]);
  const [toggle, setToggle] = useState("D");
  const [dashboardData, setDashboardData] = useState({
    transactionsByType: {
      EXPENSE: [],
      INCOME: [],
    },
    carryForward: 0,
    totalIncome: 0,
    totalExpense: 0,
    balance: 0,
    username: "anonymous",
  });
  const transactionRef = useRef(null);
  const [selectedDate, setSelectedDate] = useState(new Date());
  const [showMenu, setShowMenu] = useState(false);
  const [isDropdownOpen, setIsDropdownOpen] = useState(false); // New state for dropdown visibility
  const handleOptionSelect = (option) => {
    setSearchQuery(option);  // Set the selected option in the search input
    setSelectedOption(option); // Mark the selected option
    setIsDropdownOpen(false); // Close the dropdown after selecting
  };
  const { data, refetch, isFetching } = useGetDashboardTransactionDataQuery(
   { date:formatDate(selectedDate),selectedOption},
    {
      skip: toggle === "M" || toggle==="C",
    }
  );
  const {
    data: monthData,
    refetch: monthRefetch,
    isFetching: monthFetching,
  } = useGetMonthsQuery(
    { date: formatDate(selectedDate),selectedOption },
    {
      skip: toggle === "D" || toggle==="C",
    }
  );

  const handleStartDateChange = (e) => {
    setStartDate(e.target.value);
  };

  const handleEndDateChange = (e) => {
    setEndDate(e.target.value);
  };
  const {
    data: filteredData,
    refetch: filteredRefetch,
    isFetching: filterFetching,
  } = useGetFilteredQuery(
    { startDate: formatDate(startDate), endDate : formatDate(endDate),selectedOption },
    {
      skip: toggle === "D" || toggle==="M",
    }
  );
  console.log("filteredData",filteredData);
  
  const handleToggle = (value) => {
    setToggle(value);
    if (value === 'C') {
      setStartDate(moment().startOf('month').format('YYYY-MM-DD'));
      setEndDate(moment().endOf('month').format('YYYY-MM-DD'));
    }
  };

  function formatDate(dateString) {
    const date = new Date(dateString);
    const day = String(date.getDate()).padStart(2, "0");
    const month = String(date.getMonth() + 1).padStart(2, "0");
    const year = date.getFullYear();
    if (toggle === "M") return `${year}-${month}`;
    return `${year}-${month}-${day}`;
  }

  const handleDateChange = async (date) => {
    setSelectedDate(date);
    if (toggle === "D") {
      refetch();
    } else if(toggle === "M") {
      monthRefetch();
    }else{
      filteredRefetch()
    }
  };

  const handlePrevDate = () => {
    if (toggle === "D") {
      setSelectedDate((prevDate) => subDays(prevDate, 1));
    } else if (toggle === "M") {
      setSelectedDate((prevDate) => subMonths(prevDate, 1));
    }
  };

  const handleNextDate = () => {
    if (toggle === "D") {
      setSelectedDate((prevDate) => addDays(prevDate, 1));
    } else if (toggle === "M") {
      setSelectedDate((prevDate) => addMonths(prevDate, 1));
    }
  };

  const user = JSON.parse(localStorage.getItem("user"));

  const menuRef = useRef(null);

  const items = [
    {
      label: "Export to PDF",
      onClick: () => {
        setShowMenu(false);
        exportToPDF();
      },
    },
    {
      label: "Documentation Vault",
      onClick: () => {
        navigate("/documentation-vault",{state : {isProgrammatic:true}});
        setShowMenu(false);
      },
    },
    {
      label: "History",
      onClick: () => {
        setShowMenu(false);
        navigate("/history",{state : {isProgrammatic:true}});
      },
    },
    ...(user?.username && user?.username !== "anonymous"
      ? [
          {
            label: "Logout",
            onClick: () => {
              localStorage.clear();
              navigate("/home")
            },
          },
        ]
      : []),
  ];

  useEffect(() => {
    if (data || monthData) {
      setDashboardData({
        transactionsByType: {
          EXPENSE: data?.transactionsByType?.EXPENSE,
          INCOME: data?.transactionsByType?.INCOME,
        },
        carryForward:
          toggle === "D" ? data?.carryForward : monthData?.carryForward,
        totalIncome:
          toggle === "D" ? data?.totalIncome : monthData?.totalIncome,
        totalExpense:
          toggle === "D" ? data?.totalExpense : monthData?.totalExpense,
        balance: toggle === "D" ? data?.balance : monthData?.balance,
        username: data?.username,
      });
      if (data?.username === "anonymous") {
        localStorage.clear();
      }
    }
  }, [data, monthData]);

  const exportToPDF = () => {
    const pdf = new jsPDF("p", "mm", "a4");
    const expenseData = dashboardData.transactionsByType.EXPENSE.map(
      (val) => val
    );
    const incomeData = dashboardData.transactionsByType.INCOME.map(
      (val) => val
    );

    const { balance, carryForward, totalExpense, totalIncome } = dashboardData;

    pdf.setFontSize(16);
    pdf.text("Transaction Summary", 10, 10);

    pdf.setFontSize(12);
    pdf.text(`Balance: ${balance}`, 10, 20);
    pdf.text(`Carry Forward: ${carryForward}`, 10, 30);
    pdf.text(`Total Expense: ${totalExpense}`, 10, 40);
    pdf.text(`Total Income: ${totalIncome}`, 10, 50);

    if (expenseData && expenseData.length > 0) {
      pdf.text("Expenses", 10, 60);
      pdf.autoTable({
        head: [["Date", "Amount", "Title", "Party"]],
        body: expenseData.map((item) => [
          item.date,
          item.amount,
          item.title,
          item.party,
        ]),
        startY: 70,
      });
    }

    if (incomeData && incomeData.length > 0) {
      if (expenseData.length > 0) {
        pdf.addPage();
      }
      pdf.text("Income", 10, 10);
      pdf.autoTable({
        head: [["Date", "Amount", "Title", "Party"]],
        body: incomeData.map((item) => [
          item.date,
          item.amount,
          item.title,
          item.party,
        ]),
        startY: 20,
      });
    }

    pdf.save("transactions.pdf");
  };

  const filteredOptions = partyOptions?.filter((option) =>
    option.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const dataToRender=monthData?.dailySummaries?.length ? monthData?.dailySummaries :  filteredData?.dailySummaries
  
  return (
    <div>
      <div className="balance-card">
        <div className="header">
          <div style={{ display: "flex", gap: "5px" }}>
            <img src={logo} alt="Logo" className="logo" />
            <p style={{ fontSize: "14px", color: "#fff" }}>
              Hi, {data?.username !== "anonymous" ? data?.username : ""}
            </p>
          </div>
          <div className="user-info">
            <div className="icons">
            <div ref={searchRef} className={`search-input-container ${isSearching ? 'active' : ''}`}>
  {isSearching ? (
    <>
      <input
        type="text"
        className="search-input"
        placeholder="Search..."
        autoFocus
        value={searchQuery}
        onChange={(e) => {
          setSearchQuery(e.target.value);
          setIsDropdownOpen(true); // Open dropdown while typing
        }}
      />
      <Icon
        className="search-icon-input"
        onClick={toggleSearch}
      />
      {/* Show dropdown if dropdown is open and there are filtered options */}
      {isDropdownOpen && filteredOptions?.length > 0 && (
        <ul className="options-list">
          {filteredOptions.map((option) => (
            <li
              key={option}
              onClick={() => handleOptionSelect(option)}
              className={selectedOption === option ? 'selected' : ''}
            >
              {option}
            </li>
          ))}
        </ul>
      )}
    </>
  ) : (
    <Icon className="search-icon" onClick={toggleSearch} />
  )}
</div>




             
              <div className="dots-container">
                <FrameIcon
                  className="frame-icon"
                  onClick={() => setShowMenu(!showMenu)}
                  ref={menuRef}
                />
                {showMenu && <Menu items={items} />}
              </div>
            </div>
          </div>
        </div>
        <div className="balance-info">
          <div>
            <p>Total Balance</p>
            <h2>₹{dashboardData?.balance ?? monthData?.balance}</h2>
          </div>
          <div className="toggle-group">
            <div
              className={`toggle-btn ${toggle === "D" ? "selected" : ""}`}
              onClick={() => handleToggle("D")}
            >
              D
            </div>
            <div
              className={`toggle-btn ${toggle === "M" ? "selected" : ""}`}
              onClick={() => handleToggle("M")}
            >
              M
            </div>
            <div
              className={`toggle-btn ${toggle === "C" ? "selected" : ""}`}
              onClick={() => handleToggle("C")}
            >
              C
            </div>
          </div>
         
        </div>
       
    {toggle === 'C' && (
      <div className="custom-date-filter">
        <div className="date-input">
          <label>
            Start Date:
            <input
              type="date"
              value={startDate}
              onChange={handleStartDateChange}
            />
          </label>
        </div>
        <div className="date-input">
          <label>
            End Date:
            <input
              type="date"
              value={endDate}
              onChange={handleEndDateChange}
            />
          </label>
        </div>
      </div>
    )}
        <div className="date-selector">
          <button className="prev-date" onClick={handlePrevDate}>
            {"<"}
          </button>
          <div className="date-display">
            {toggle === "D" ? (
              <DatePicker
                selected={selectedDate}
                onChange={handleDateChange}
                dateFormat="d, MMM yy EEE"
              />
            ) : (
              <DatePicker
                selected={selectedDate}
                onChange={handleDateChange}
                dateFormat="MMM yy"
                showMonthYearPicker
              />
            )}
          </div>
          <button className="next-date" onClick={handleNextDate}>
            {">"}
          </button>
        </div>
      </div>
      <div className="c-f">
        <span>C/F</span>
        <span>₹{dashboardData?.carryForward ?? monthData?.carryForward}</span>
      </div>
      <div className="summary">
        <div className="summary-item">
          <div className="summary-icon">
            <IncomeIcon style={{ width: "24px", height: "44px" }} />
          </div>
          <div className="text">
            <p>Total Income</p>
            <h3 className="amount positive">
              ₹{dashboardData?.totalIncome ?? monthData?.totalIncome}
            </h3>
          </div>
        </div>
        <div className="summary-item">
          <div className="summary-icon-ex">
            <ExpenseIcon style={{ width: "24px", height: "44px" }} />
          </div>
          <div className="text">
            <p>Total Expenses</p>
            <h3 className="amount negative">
              ₹{dashboardData?.totalExpense ?? monthData?.totalExpense}
            </h3>
          </div>
        </div>
      </div>
      {toggle === "D" && (
        <>
          {isFetching ? (
            <SkeletonCard /> // Render a skeleton for TransactionInfo while fetching
          ) : (
            <TransactionInfo
              transactionRef={transactionRef}
              expense={dashboardData?.transactionsByType?.EXPENSE}
              income={dashboardData?.transactionsByType?.INCOME}
            />
          )}
        </>
      )}

      {(toggle === "M" || toggle==="C") && (
        <div
          style={{
            padding: "10px",
            display: "flex",
            gap: "20px",
            flexDirection: "column",
          }}
        >
          {monthFetching || filterFetching ? (
            <>
              {[...Array(3)].map((_, index) => (
                <MonthlyInfoSkeleton key={index} />
              ))}
            </>
          ) : (
            dataToRender?.map((val, index) => (
              <MonthlyInfo
                key={index}
                val={val}
                handleToggle={handleToggle}
                handleDateChange={handleDateChange}
              />
            ))
          )}
        </div>
      )}
    </div>
  )
}

export default BalanceCard;
