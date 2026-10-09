import React, { useState } from "react";
import { ReactComponent as Cross } from "../../assets/svgs/cross.svg";
import { ReactComponent as UploadIcon } from "../../assets/svgs/Folder2.svg";

import "./index.css";
import { useAddSubFileMutation } from "../../service/api";
import { toast } from "react-toastify";

const UploadFile = ({ isOpen, handleCloseModal, folderId }) => {
  const [files, setFiles] = useState([]);
  const [uploadFile, { isLoading: fileLoading }] = useAddSubFileMutation();

  const handleFileChange = async (event) => {
    try {
      const newFile = event.target.files[0];
      if (newFile) {
        setFiles((prevFiles) => [...prevFiles, newFile]);

        const formData = new FormData();
        formData.append("file", newFile);
        formData.append("folderId", folderId);

        const res = await uploadFile(formData);
        if (res?.data?.success) {
          toast.success(res?.data?.message);
        } else {
          toast.error(res?.error?.data?.message);
        }
      }
    } catch (error) {
      toast.success(error?.data?.message);
    } finally {
      event.target.value = "";
    }
  };
  const handleRemoveFile = (index) => {
    setFiles((prevFiles) => prevFiles.filter((_, i) => i !== index));
  };
  const handleClose = () => {
    setFiles([]);
    handleCloseModal();
  };
  return (
    <div className={`modal-overlay ${isOpen ? "show" : ""}`}>
      <div
        className={`modal-content ${isOpen ? "slide-up" : ""}`}
        onClick={(e) => e.stopPropagation()}
      >
        <div className="top-heading">
          <h2>Upload File</h2>
          <Cross onClick={handleClose} />
        </div>

        <div className="modal-upload input-group_">
          <label>Upload Document</label>
          <div className="upload-box">
            <input
              type="file"
              onChange={handleFileChange}
              style={{ display: "none" }}
              id="fileInput"
            />
            <label htmlFor="fileInput" className="upload-box-label">
              Browse Files
            </label>
            <p>JPG, PNG, PDF, EXCEL</p>
          </div>
          <div className="file-preview">
            {files?.map((file, index) => {
              let previewUrl;

              try {
                previewUrl = URL.createObjectURL(file);
              } catch (error) {
                console.error("Error creating object URL:", error);

                const fileExtension = file?.name
                  ?.split(".")
                  .pop()
                  .toLowerCase();

                switch (fileExtension) {
                  case "png":
                  case "jpg":
                  case "jpeg":
                  case "gif":
                    previewUrl =
                      "https://via.placeholder.com/150?text=Image+Preview";
                    break;
                  case "pdf":
                    previewUrl =
                      "https://via.placeholder.com/150?text=PDF+Preview";
                    break;
                  case "doc":
                  case "docx":
                    previewUrl =
                      "https://via.placeholder.com/150?text=Word+Preview";
                    break;
                  case "xls":
                  case "xlsx":
                    previewUrl =
                      "https://via.placeholder.com/150?text=Excel+Preview";
                    break;
                  default:
                    previewUrl =
                      "https://via.placeholder.com/150?text=File+Preview";
                }
              }

              return (
                <div key={index} className="file-item">
                  <img
                    src={previewUrl}
                    alt="file preview"
                    className="file-preview-image"
                  />
                  <span className="file-name">
                    {file?.name ?? file.filename}
                  </span>
                  <Cross
                    onClick={() => handleRemoveFile(index)}
                    className="remove-file-icon"
                  />
                </div>
              );
            })}
          </div>
        </div>
        <button className="modal-add-button" onClick={handleClose}>
          Add File
        </button>
      </div>
    </div>
  );
};

export default UploadFile;
