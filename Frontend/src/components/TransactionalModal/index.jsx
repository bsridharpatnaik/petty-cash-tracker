import React, { useEffect, useState } from "react";
import { ReactComponent as Cross } from "../../assets/svgs/cross.svg";
import CreatableSelect from "react-select/creatable";
import "./index.css";
import {
  useCreateTransactionMutation,
  useGetExistingPartyQuery,
  useUpdateTransactionMutation,
  useUploadFileMutation,
} from "../../service/api";
import { toast } from "react-toastify";

const AddTransactionModal = ({dataToShow, isOpen, setIsModalOpen, isUpdate }) => {
  const { data, isLoading: existingPartyloading } = useGetExistingPartyQuery();
  const [createTransaction, { isLoading: creatingTransactionLoading }] =
    useCreateTransactionMutation();
  const [uploadFile, { isLoading: fileLoading }] = useUploadFileMutation();
  const [update, { isLoading: updateLoading }] = useUpdateTransactionMutation();
  const currentDate = new Date().toISOString().split("T")[0]; // Get current date in YYYY-MM-DD format

  const [files, setFiles] = useState([]);
  const [filesDetail, setFilesDetail] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [options, setOptions] = useState([]);
  const [value, setValue] = useState();
  const [submissionData, setSubmissionData] = useState({});
  
  useEffect(() => {
    const defaultValue = {
      title: dataToShow?.title ?? "",
      amount: dataToShow?.amount !== undefined ? dataToShow.amount : null, 
      selectedParty: dataToShow?.party,
      date:dataToShow?.date ?? currentDate,
      transactionType: dataToShow?.transactionType ?? "INCOME",
    };
    setSubmissionData(defaultValue);
    if (dataToShow.party) {
      setValue(createOption(dataToShow.party));
    }
    setFilesDetail(dataToShow?.fileInfos || []);
    setFiles(dataToShow?.fileInfos || []);
  }, [dataToShow]);
  const customStyles = {
    control: (provided) => ({
      ...provided,
      width: "100%",
      border: "1px solid #E0E0E0",
      borderRadius: "5px",
      backgroundColor: "#F9F9F9",
    }),
    menu: (provided) => ({
      ...provided,
      borderRadius: "5px",
      zIndex: 2,
    }),
    input: (provided) => ({
      ...provided,
      padding: "2px",
      fontSize: "14px",
    }),
  };

  const createOption = (label) => ({
    label,
    value: label,
  });

  const handleCreate = (inputValue) => {
    setIsLoading(true);
    setTimeout(() => {
      const newOption = createOption(inputValue);
      setOptions((prev) => [...prev, newOption]);
      setValue(newOption);
      setIsLoading(false);
      setSubmissionData((prevState) => ({
        ...prevState,
        selectedParty: inputValue, 
      }));
    }, 1000);
  };

  const handleFileChange = async (event) => {
    try {
      const newFile = event.target.files[0];
      if (newFile) {
        setFiles((prevFiles) => [...prevFiles, newFile]);
        const formData = new FormData();
        formData.append("file", newFile);
        const response = await uploadFile(formData);
        setFilesDetail((prev) => [
          ...prev,
          {
            fileUuid: response?.data?.fileUuid,
            filename: response?.data?.filename,
          },
        ]);
      }
    } catch (error) {
      console.log("Error", error);
    }
  };


  const handleRemoveFile = (index) => {
    setFiles((prevFiles) => prevFiles.filter((_, i) => i !== index));
  };

  const handleInputChange = (e, name) => {
    const { value, type, checked } = e.target;
    setSubmissionData((prevState) => ({
      ...prevState,
      [name]: type === "checkbox" ? checked : value,
    }));
  };

  function getFormattedDate() {
    const today = new Date();
    const day = String(today.getDate()).padStart(2, "0");
    const month = String(today.getMonth() + 1).padStart(2, "0");
    const year = today.getFullYear();
    return `${day}-${month}-${year}`;
  }

  const handleSelectChange = (selectedOption) => {
    setValue(selectedOption); 
    setSubmissionData((prevState) => ({
      ...prevState,
      selectedParty: selectedOption ? selectedOption.value : null,
    }));
  };
  const submitRequest = async (e) => {
    e.stopPropagation();
    const formattedDate = formatDateForSubmission(submissionData.date);

    const data = {
      transactionType: submissionData?.transactionType.toUpperCase(),
      date: formattedDate,
      title: submissionData?.title,
      party: submissionData?.selectedParty,
      amount: submissionData?.amount,
      files: filesDetail,
    };
   try{
    if(isUpdate){
      const { date, ...otherData } = data;
  
      const dateObj = new Date(date);
      const formattedDate = [
        String(dateObj.getDate()).padStart(2, '0'),       
        String(dateObj.getMonth() + 1).padStart(2, '0'),   
        dateObj.getFullYear()                              
      ].join('-');                                        
    
  
      const updatedData = { ...otherData, date: formattedDate };
    
      const response = await update({ id: dataToShow.id, data: updatedData });
     if(response?.error){
      toast.error(response?.error?.data?.message)
    }else{
      setSubmissionData({
        title: "",
        amount: 0,
        selectedParty: null,
        date:null,
        transactionType: "Income",
      });
      setValue({})
      setFiles([]);
      setFilesDetail([]);
      setIsModalOpen(false)
      toast.success("Updated Successfully")
    }
    }else{
      const response = await createTransaction(data);
      if(response?.error){
        toast.error(response?.error?.data?.message)
      }else{
        setSubmissionData({
          title: "",
          amount: 0,
          selectedParty: null,
          date:null,
          transactionType: "Income",
        });
        setValue({})
        setFiles([]);
        setFilesDetail([]);
        setIsModalOpen(false)

        toast.success("Added Successfully")
      }

    }
   }catch(error){
    setSubmissionData({
      title: "",
      amount: 0,
      selectedParty: null,
      date:null,
      transactionType: "Income",
    });
    setValue({})
    setFiles([]);
    setFilesDetail([]);
   }
  };
  const formatDateForSubmission = (dateStr) => {
    const [year, month, day] = dateStr.split("-");
    return `${day}-${month}-${year}`;
  };
  useEffect(() => {
    if (data && data.length > 0) {
      const newArr = data.map((item) => ({ label: item, value: item }));
      setOptions(newArr); 
    }
  }, [data]);
  const handleCloseModal=()=>{
    setIsModalOpen(false)
    setSubmissionData({
      title: "",
      amount: 0,
      selectedParty: null,
      date:null,
      transactionType: "Income",
    });
    setValue({})
    setFiles([]);
    setFilesDetail([]);
  }
  const convertToDisplayFormat = (dateStr) => {
    const [day, month, year] = dateStr.split("-");
    return `${year}-${month}-${day}`; // yyyy-mm-dd format
  };
  
  return (
    <div className={`modal-overlay ${isOpen ? "show" : ""}`}>
      <div
        className={`modal-content ${isOpen ? "slide-up" : ""}`}
        onClick={(e) => e.stopPropagation()}
      >
        <div className="top-heading">
          <h2>{isUpdate ? `Update` : `Add`}</h2>
          <Cross onClick={handleCloseModal} />
        </div>
        <div className="modal-radio-group">
          <label>
            <input
              type="radio"
              name="transactionType"
              value="INCOME"
              checked={submissionData?.transactionType === "INCOME" }
              onChange={(e) => handleInputChange(e, "transactionType")}
              defaultChecked
            />
            Income
          </label>
          <label>
            <input
              type="radio"
              name="transactionType"
              value="EXPENSE"
              checked={submissionData?.transactionType === "EXPENSE"}
              onChange={(e) => handleInputChange(e, "transactionType")}
            />
            Expenses
          </label>
        </div>

        <div className="input-group_">
          <label htmlFor="inputField">Title</label>
          <div className="input-wrapper_">
            <input
              id="inputField"
              type="text"
              value={submissionData?.title}
              onChange={(e) => handleInputChange(e, "title")}
              placeholder="Enter Title"
            />
          </div>
        </div>

        <div className="input-group_">
          <label htmlFor="inputField">Amount</label>
          <div className="input-wrapper_">
            <input
              id="inputField"
              value={submissionData?.amount}
              onChange={(e) => handleInputChange(e, "amount")}
              type="number"
              placeholder="Enter Amount"
            />
          </div>
        </div>
        <div className="input-group_">
          <label htmlFor="inputField">Date</label>
          <div className="input-wrapper_">
            <input
              id="inputField"
              value={(submissionData?.date && dataToShow?.date) ? convertToDisplayFormat(submissionData.date) : submissionData.date}
              onChange={(e) => handleInputChange(e, "date")}
              type="date"
              placeholder="DD/MM/YYYY" 
            />
          </div>
        </div>
        <div className="input-group_">
          <label>Select Party</label>
           <CreatableSelect
            isClearable
            isDisabled={isLoading}
            isLoading={isLoading}
            onChange={handleSelectChange} 
            onCreateOption={handleCreate} 
            options={options}
            styles={customStyles}
            value={value} 
           />
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
    <div key={index} className="file-item">
      <img
        src={previewUrl}
        alt="file preview"
        className="file-preview-image"
      />
      <span className="file-name">{file?.name ?? file.filename}</span>
      <Cross
        onClick={() => handleRemoveFile(index)}
        className="remove-file-icon"
      />
    </div>
  );
})}

          </div>
        </div>

        <button onClick={submitRequest} className="modal-add-button">
         {isUpdate ? "Update" : "Add"}
        </button>
      </div>
    </div>
  );
};

export default AddTransactionModal;
