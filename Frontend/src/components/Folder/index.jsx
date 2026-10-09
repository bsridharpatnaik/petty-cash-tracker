import React, { useRef, useState } from "react";
import "./index.css";
import { ReactComponent as FolderIcon } from "../../assets/svgs/Folder.svg";
import { useDeleteFileMutation, useDeleteFolderMutation, useDownloadFileQuery } from "../../service/api";
import { toast } from "react-toastify";
import Menu from "../Menu";
import { useEffect } from "react";
import { ReactComponent as Dots } from "../../assets/svgs/blackdots.svg";
import Swal from "sweetalert2";

const Folder = ({ item, file, refetch, setFolderId,folderId}) => {
 const[deleteFolder] = useDeleteFolderMutation()
 const[deleteFile] = useDeleteFileMutation() 
  const[showMenu,setShowMenu]=useState(false)
  const[fileDownload,setFileDownload]=useState(false)
  // const {data} =useDownloadFileQuery({
  //     id:item.id
  // },{
  //  skip:!file || !fileDownload
  // })
  const downloadFile = async () => {
    try {
      const response = await fetch(`${process.env.REACT_APP_BASE_URL}/vault/files/download/${item.id}`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/octet-stream',
        },
      });
      if (!response.ok) {
        throw new Error('Failed to download file');
      }
  
      const blob = await response.blob(); // Convert the response to a blob
  
      // Extract the filename from content-disposition if available
      const contentDisposition = response.headers.get('content-disposition');
      let filename = item.filename;
  
      if (contentDisposition && contentDisposition.includes('filename=')) {
        filename = contentDisposition.split('filename=')[1].trim().replace(/['"]/g, '');
      }
  
      // Create a temporary anchor element for triggering download
      const url = window.URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', filename); // Filename for download
      document.body.appendChild(link);
      link.click();
      link.parentNode.removeChild(link); // Clean up the DOM
      window.URL.revokeObjectURL(url); // Revoke the object URL
    } catch (error) {
      console.error('Error while downloading the file:', error);
    }
  };
  
  // Function to fetch the folder details
  const fetchFolder = () => {
    setFolderId(item.id || "");
  };

  // Function to determine the preview URL based on file extension
  const getPreviewUrl = (filename) => {
    const fileExtension = filename?.split(".").pop().toLowerCase();

    let previewUrl = "";
    switch (fileExtension) {
      case "png":
      case "jpg":
      case "jpeg":
      case "gif":
        previewUrl = "https://via.placeholder.com/150?text=Image+Preview";
        break;
      case "pdf":
        previewUrl = "https://via.placeholder.com/150?text=PDF+Preview";
        break;
      case "doc":
      case "docx":
        previewUrl = "https://via.placeholder.com/150?text=Word+Preview";
        break;
      case "xls":
      case "xlsx":
        previewUrl = "https://via.placeholder.com/150?text=Excel+Preview";
        break;
      default:
        previewUrl = "https://via.placeholder.com/150?text=File+Preview";
    }
    return previewUrl;
  };
  const handleClick = async (e) => {
  
    Swal.fire({
      title: 'Are you sure?',
      text: "Do you really want to delete this item? This action cannot be undone!",
      icon: 'warning',
      showCancelButton: true,
      confirmButtonColor: '#3085d6',
      cancelButtonColor: '#d33',
      confirmButtonText: 'Yes, delete it!'
    }).then(async (result) => {
      if (result.isConfirmed) {
        try {
          // If `file` is true, delete file; otherwise, delete folder
          const res = file ? await deleteFile(item.id) : await deleteFolder(item.id);
  
          console.log("Res", res);
  
          // Check for success and show appropriate toast
          if (res?.data?.success) {
            toast.success(res.data.message);
            Swal.fire(
              'Deleted!',
              'Your item has been deleted.',
              'success'
            );
          }
        } catch (err) {
          console.log("Err", err);
          toast.error(err?.data?.message || 'Something went wrong');
          Swal.fire(
            'Error',
            'Something went wrong while deleting!',
            'error'
          );
        }
      }
    });
  };
  
const menuRef = useRef(null);

const handleClickOutside = (event) => {
  if (menuRef.current && !menuRef.current.contains(event.target)) {
    setShowMenu(false);
  }
};
const items = [
  ...(file ? [{
    label: "Download",
    onClick: () => {
      downloadFile()
      setShowMenu(false);
    },
  }] : []),
  {
    label: "Delete",
    onClick: () => {
      handleClick();
      setShowMenu(false);
    },
  },
];

useEffect(() => {
  document.addEventListener("mousedown", handleClickOutside);
  return () => {
    document.removeEventListener("mousedown", handleClickOutside);
  };
}, []);
  return (
    <div onClick={fetchFolder} className="transaction-item">
      <div className="transaction-icon-folder">
        {file ? (
          <img
            src={getPreviewUrl(item.filename)}
            alt="file preview"
            style={{ width: "50px", height: "50px" }} // Adjust the size as needed
          />
        ) : (
          <FolderIcon />
        )}
      </div>
      <div className="transaction-details">
      <span>  {file ? item?.filename : item.name}</span>
        <p style={{ marginTop: "3px", color: "#A6AEC1", fontWeight: "200" }}>
          {item.itemCount}
        </p>
      </div>
      <span style={{ color: "#A6AEC1", fontSize: "12px",marginTop:"20px" }}>
        {item.lastUpdateDate || ""}
      </span>
      <div
        className="dots-container"
        ref={menuRef}
        style={{ position: "relative" }}
       >

          <Dots className="frame-icon" onClick={(e) => {
  e.stopPropagation();
  setShowMenu(!showMenu);
}}
 />
        
        {showMenu && <Menu items={items} />}
      </div>
    </div>
  );
};

export default Folder;
