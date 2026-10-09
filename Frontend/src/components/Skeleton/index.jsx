import Skeleton from "react-loading-skeleton";
import 'react-loading-skeleton/dist/skeleton.css';

import "../Transaction/index.css"
const SkeletonCard = () => {
    return (
      <div className="transaction-item" style={{ borderBottom: "1px solid #F7F9FC" }}>
        <div className="transaction-icon">
          <Skeleton circle={true} height={40} width={40} />
        </div>
        <div className="transaction-details">
          <Skeleton width={150} height={20} />
          <Skeleton width={100} height={15} style={{ marginTop: "5px" }} />
        </div>
      </div>
    );
  };
  export default SkeletonCard