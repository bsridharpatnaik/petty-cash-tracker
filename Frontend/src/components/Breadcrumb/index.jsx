import React, { useEffect, useState } from "react";
import "./index.css";

const Breadcrumb = ({ data, setFolderId }) => {
  const [folderData, setFolderData] = useState([]);
  const onlyOne = folderData.length === 1;
  const shouldShowEllipsis = folderData.length > 3;
  let secondPlaceData = "";
  if (folderData.length > 1) {
    secondPlaceData = folderData[1];
  }
  const lastLink = folderData[folderData.length - 1];

  const fetchClickedTitleinfo = (folderId)=>{
    setFolderId(folderId);
  }

  useEffect(() => {
    if (data.length > 0) {
      setFolderData(data);
    }
  }, [data]);

  return (
    <nav aria-label="breadcrumb">
      <ol className="breadcrumb">
        <li className="breadcrumb-item">
          <span onClick={()=>fetchClickedTitleinfo(folderData[0].id)}>Home</span>
          <div>&nbsp;/&nbsp;</div>
          <span onClick={()=>fetchClickedTitleinfo(folderData[1].id)}>{secondPlaceData.name}&nbsp;</span>
          {folderData.length === 3 && <span onClick={()=>fetchClickedTitleinfo(folderData[2].id)}>/ {folderData[2].name}</span>}
        </li>
        {shouldShowEllipsis && <li className="breadcrumb-item">/ ... /</li>}
        {!shouldShowEllipsis &&
          folderData.slice(2, folderData.length - 1).map((item, index) => (
            <li onClick={()=>fetchClickedTitleinfo(folderData[index+2].id)} key={index} className="breadcrumb-item">
              <span>/ {item.name}</span>
            </li>
          ))}
        <li className="breadcrumb-item">
          {shouldShowEllipsis && <span>{lastLink.name}</span>}
        </li>
      </ol>
    </nav>
  );
};

export default Breadcrumb;
