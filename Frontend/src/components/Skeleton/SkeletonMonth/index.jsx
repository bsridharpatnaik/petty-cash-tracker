import React from "react";
import Skeleton from "react-loading-skeleton";
import "react-loading-skeleton/dist/skeleton.css"; // Import Skeleton CSS
import "./index.css";

const MonthlyInfoSkeleton = () => {
  return (
    <div className="transaction-container">
      <div className="transaction-header">
        <Skeleton width={100} height={20} /> {/* Date */}
        <Skeleton width={80} height={20} /> {/* Carry Forward */}
      </div>

      <div className="transaction-grid">
        {/* Income Section Skeleton */}
        <div className="transaction-income">
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
            <Skeleton width={50} height={15} /> {/* Income Label */}
            <Skeleton width={80} height={25} /> {/* Income Amount */}
          </div>
          <div className="transaction-list">
            {[...Array(3)].map((_, index) => (
              <div key={index} className="transaction-item">
                <div className="text_">
                  <Skeleton width={100} height={15} /> {/* Category */}
                  <Skeleton width={100} height={15} /> {/* Vendor */}
                </div>
                <Skeleton width={50} height={15} /> {/* Amount */}
              </div>
            ))}
          </div>
        </div>

        {/* Expense Section Skeleton */}
        <div className="transaction-expense">
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
            <Skeleton width={60} height={15} /> {/* Expenses Label */}
            <Skeleton width={80} height={25} /> {/* Expense Amount */}
          </div>
          <div className="transaction-list">
            {[...Array(3)].map((_, index) => (
              <div key={index} className="transaction-item">
                <div className="text_">
                  <Skeleton width={100} height={15} /> {/* Category */}
                  <Skeleton width={100} height={15} /> {/* Vendor */}
                </div>
                <Skeleton width={50} height={15} /> {/* Amount */}
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="transaction-balance">
        <Skeleton width={60} height={20} /> {/* Balance Label */}
        <Skeleton width={80} height={25} /> {/* Balance Amount */}
      </div>
    </div>
  );
};

export default MonthlyInfoSkeleton;
