import React, { useEffect, useState } from "react";
import "./index.css";
import { ReactComponent as Cross } from "../../assets/svgs/cross.svg";

import { ReactComponent as Edit } from "../../assets/svgs/EditModal.svg";
import { ReactComponent as Delete } from "../../assets/svgs/DeleteModal.svg";
import AddTransactionModal from "../TransactionalModal";
import * as XLSX from "xlsx"
const TransactionOpenPopup = ({
  isOpen,
  activeTab,
  date,
  historyLog,
  item,
  handleCloseModal,
  convertToTimeFormat,
  showDetails,
  handleDelete
}) => {
  const user = JSON.parse(localStorage.getItem("user"));
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isUpdate, setIsUpdate] = useState(false);
  const [dataToShow, setdataToShow] = useState({});
  const[files,setFiles]=useState([])
  const handleAddButtonClick = () => {
    setdataToShow(item);
    setIsModalOpen(true);
    setIsUpdate(true);
  };
  useEffect(()=>{
    setFiles(item.fileInfos)
  },[item?.id,item?.fileInfos?.length])


  const downloadFile = async (file) => {
    try {
      console.log('Starting file preview for:', file.filename);
  
      const response = await fetch(`${process.env.REACT_APP_BASE_URL}/file/download/${file.fileUuid}`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${user?.token}`
        },
      });
  
      if (!response.ok) {
        throw new Error(`Failed to fetch file: ${response.status} ${response.statusText}`);
      }
    
      console.log('File fetched successfully');
  
      const blob = await response.blob();
      const url = window.URL.createObjectURL(blob);
      const fileType = file.filename.split('.').pop().toLowerCase();
  
      let previewElement;
  
      switch (fileType) {
        case 'xlsx':
        case 'xls':
          previewElement = document.createElement('div');
          previewElement.style.width = '100%';
          previewElement.style.height = '600px';
          previewElement.style.overflow = 'auto';
          
          // Load SheetJS library dynamically
          const script = document.createElement('script');
          script.src = 'https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js';
          document.head.appendChild(script);
          
          script.onload = async () => {
            const arrayBuffer = await blob.arrayBuffer();
            const workbook = XLSX.read(arrayBuffer, { type: 'array' });
            
            // Create a table container
            const tableContainer = document.createElement('div');
            tableContainer.style.padding = '10px';
            
            // Process each sheet in the workbook
            workbook.SheetNames.forEach((sheetName, index) => {
              const sheet = workbook.Sheets[sheetName];
              
              // Create sheet header
              const sheetHeader = document.createElement('h3');
              sheetHeader.textContent = `Sheet: ${sheetName}`;
              sheetHeader.style.margin = '20px 0 10px 0';
              sheetHeader.style.padding = '5px';
              sheetHeader.style.backgroundColor = '#f0f0f0';
              
              // Convert sheet data to HTML table
              const htmlTable = XLSX.utils.sheet_to_html(sheet, { editable: false });
              const tableWrapper = document.createElement('div');
              tableWrapper.innerHTML = htmlTable;
              
              // Style the table
              const table = tableWrapper.querySelector('table');
              if (table) {
                table.style.borderCollapse = 'collapse';
                table.style.width = '100%';
                table.style.marginBottom = '20px';
                
                // Style table cells
                const cells = table.getElementsByTagName('td');
                Array.from(cells).forEach(cell => {
                  cell.style.border = '1px solid #ddd';
                  cell.style.padding = '8px';
                  cell.style.textAlign = 'left';
                });
                
                // Style table headers
                const headers = table.getElementsByTagName('th');
                Array.from(headers).forEach(header => {
                  header.style.border = '1px solid #ddd';
                  header.style.padding = '8px';
                  header.style.textAlign = 'left';
                  header.style.backgroundColor = '#f4f4f4';
                });
              }
              
              tableContainer.appendChild(sheetHeader);
              tableContainer.appendChild(tableWrapper);
            });
            
            previewElement.appendChild(tableContainer);
          };
          break;
          
        case 'pdf':
          previewElement = document.createElement('div');
          previewElement.style.width = '100%';
          previewElement.style.height = '600px';
          previewElement.style.overflow = 'auto';
          
          // Load PDF.js library dynamically
          const pdfScript = document.createElement('script');
          pdfScript.src = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.9.359/pdf.min.js';
          document.head.appendChild(pdfScript);
          
          pdfScript.onload = async () => {
            const pdfjsLib = window['pdfjs-dist/build/pdf'];
            pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.9.359/pdf.worker.min.js';
            
            const pdf = await pdfjsLib.getDocument(url).promise;
            const totalPages = pdf.numPages;
            
            for (let pageNum = 1; pageNum <= totalPages; pageNum++) {
              const page = await pdf.getPage(pageNum);
              const scale = 1.5;
              const viewport = page.getViewport({ scale });
              
              const canvas = document.createElement('canvas');
              const context = canvas.getContext('2d');
              canvas.height = viewport.height;
              canvas.width = viewport.width;
              
              const renderContext = {
                canvasContext: context,
                viewport: viewport
              };
              
              await page.render(renderContext).promise;
              previewElement.appendChild(canvas);
            }
          };
          break;
  
        case 'jpg':
        case 'jpeg':
        case 'png':
        case 'gif':
          previewElement = document.createElement('img');
          previewElement.src = url;
          previewElement.alt = file.filename;
          previewElement.style.maxWidth = '100%';
          previewElement.style.height = 'auto';
          break;
  
        case 'mp4':
        case 'webm':
          previewElement = document.createElement('video');
          previewElement.src = url;
          previewElement.controls = true;
          previewElement.style.maxWidth = '100%';
          break;
  
        default:
          previewElement = document.createElement('a');
          previewElement.href = url;
          previewElement.download = file.filename;
          previewElement.textContent = `Download ${file.filename}`;
      }
  
      console.log('Preview element created:', previewElement.tagName);
  
      // Create modal container
      const modalContainer = document.createElement('div');
      modalContainer.style.position = 'fixed';
      modalContainer.style.top = '0';
      modalContainer.style.left = '0';
      modalContainer.style.width = '100%';
      modalContainer.style.height = '100%';
      modalContainer.style.backgroundColor = 'rgba(0, 0, 0, 0.5)';
      modalContainer.style.display = 'flex';
      modalContainer.style.justifyContent = 'center';
      modalContainer.style.alignItems = 'center';
      modalContainer.style.zIndex = '1000';
  
      // Create modal content
      const modalContent = document.createElement('div');
      modalContent.style.backgroundColor = 'white';
      modalContent.style.padding = '20px';
      modalContent.style.borderRadius = '5px';
      modalContent.style.maxWidth = '90%';
      modalContent.style.maxHeight = '90%';
      modalContent.style.overflow = 'auto';
      modalContent.style.display = 'flex';
      modalContent.style.flexDirection = 'column';
  
      // Create close button
      const closeButton = document.createElement('button');
      closeButton.textContent = 'Close';
      closeButton.style.marginTop = '10px';
      closeButton.style.alignSelf = 'flex-end';
      closeButton.onclick = () => {
        document.body.removeChild(modalContainer);
        window.URL.revokeObjectURL(url);
      };
  
      // Append elements
      modalContent.appendChild(previewElement);
      modalContent.appendChild(closeButton);
      modalContainer.appendChild(modalContent);
      document.body.appendChild(modalContainer);
  
    } catch (error) {
      console.error('Error while previewing the file:', error);
      alert(`Error previewing file: ${error.message}`);
    } finally {
      setIsModalOpen(false);
    }
  };
  return (
    <div className={`modal-overlay ${isOpen ? "show" : ""}`}>
      <div
        className={`modal-content ${isOpen ? "slide-up" : ""}`}
        onClick={(e) => e.stopPropagation()}
      >
       <div style={{width:"100%" , display:"flex",justifyContent:"flex-end"}}>
       <Cross onClick={handleCloseModal} />
        </div>

        <div className="top-heading">
          <h2>Transaction History</h2>
          <div style={{display:"flex",gap:"5px"}}>
            <Edit onClick={handleAddButtonClick} />
            <Delete onClick={handleDelete} />
          </div>
        </div>
        <div className="transaction-item">
          <div className="transaction-icon">
            {activeTab?.toUpperCase()?.substring(0, 1)}
          </div>
          <div className="transaction-details">
            <strong>{item?.title}</strong>
            {historyLog && (
              <span style={{ color: "#666875" }}> &nbsp;{item?.message}</span>
            )}
            {date ? (
              <>
                <p
                  style={{
                    marginTop: "3px",
                    color: "#A6AEC1",
                    fontWeight: "200",
                  }}
                >
                  {item?.creationDate}
                </p>{" "}
              </>
            ) : (
              <>
                <p>{item?.party}</p>
              </>
            )}
          </div>
          {showDetails && (
            <div className="transaction-amt">
              <div className="transaction-amount positive">₹{item?.amount}</div>
              <div className="transaction-time">
                {convertToTimeFormat(item?.modificationDate)}
              </div>
            </div>
          )}
        </div>
        <div className="file-preview">
          {files?.map((file, index) => {
  let previewUrl;

  try {
    previewUrl = URL.createObjectURL(file);
  } catch (error) {
    console.error("Error creating object URL:", error);

    const fileExtension = file?.name?.split('.').pop().toLowerCase();

    switch (fileExtension) {
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
        previewUrl = 'https://via.placeholder.com/150?text=Image+Preview';
        break;
      case 'pdf':
        previewUrl = 'https://via.placeholder.com/150?text=PDF+Preview';
        break;
      case 'doc':
      case 'docx':
        previewUrl = 'https://via.placeholder.com/150?text=Word+Preview';
        break;
      case 'xls':
      case 'xlsx':
        previewUrl = 'https://via.placeholder.com/150?text=Excel+Preview';
        break;
      default:
        previewUrl = 'https://via.placeholder.com/150?text=File+Preview';
    }
  }

  return (
    <div key={index} className="file-item" onClick={()=>downloadFile(file)}>
      <img
        src={previewUrl}
        alt="file preview"
        className="file-preview-image"
      />
      <span className="file-name">{file?.name ?? file.filename}</span>
    </div>
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

export default TransactionOpenPopup;
