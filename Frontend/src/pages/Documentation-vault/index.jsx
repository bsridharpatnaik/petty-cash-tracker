import React, { useEffect, useState } from "react";
import Folder from "../../components/Folder";
import { ReactComponent as Left } from "../../assets/svgs/arrowleft.svg";
import AddButton from "../../components/AddButton";
import Menu from "../../components/Menu";
import Breadcrumb from "../../components/Breadcrumb";
import { useGetDocumentationVaultQuery } from "../../service/api";
import UploadFolder from "../../components/UploadFolder/index";
import UploadFile from "../../components/UploadFile/index";
import { useLocation, useNavigate } from "react-router-dom";
import SkeletonCard from "../../components/Skeleton";

const Documentation = () => {
  const [showMenu, setShowMenu] = useState(false);
  const [folderId, setFolderId] = useState("");
  const [folderData, setFolderData] = useState();
  const [isOpen, setIsOpen] = useState(false);
  const [isFileOpen, setIsFileOpen] = useState(false);
  const navigate=useNavigate()
  const location=useLocation()
  useEffect(() => {
    // If the navigation is not programmatic, redirect to /home
    if (!location.state?.isProgrammatic) {
      navigate('/home');
    }
  }, [location.state, navigate]);
  const { data: fetchedData, refetch,isFetching } =
    useGetDocumentationVaultQuery(folderId);
  const items = [
    {
      label: "Add Folder",
      onClick: () => {
        setIsOpen(true);
        setShowMenu(false);
      },
    },
    {
      label: "Add File",
      onClick: () => {
        setIsFileOpen(true);
        setShowMenu(false);
      },
    },
  ];

  const backClick = () => {
    if(folderData.parentFolderId){
      setFolderId(folderData.parentFolderId)
    }else{
      navigate("/dashboard",{state:{isProgrammatic:true}})
    }
  };

  useEffect(() => {
    if (fetchedData) {
      setFolderData(fetchedData);
    }
  }, [fetchedData]);

  useEffect(() => {
    if (folderData?.name !== "root") refetch();
  }, [folderId]);

  return (
    <div className="wrapper">
      <div className="wrapper_container_heading">
        <div className="text_container">
          <Left onClick={backClick} />
          <h5>Document Vault</h5>
        </div>
        <Breadcrumb data={folderData?.breadcrumb || []} setFolderId={setFolderId} />
      </div>
      {isFetching ? (
        <>
          {Array(4)
            .fill()
            .map((_, index) => (
              <SkeletonCard key={index} />
            ))}
        </>
      ) : (
        <>
          {folderData?.subFolders.map((item, index) => (
            <Folder
              key={index}
              item={item}
              file={false}
              folderId={folderId}
              refetch={refetch}
              setFolderId={setFolderId}
            />
          ))}
          {folderData?.files.map((item, index) => (
            <Folder
              key={index}
              item={item}
              file={true}
              folderId={folderId}
              refetch={refetch}
              setFolderId={setFolderId}
            />
          ))}
        </>
      )}
      <div className="add-btn">
        <AddButton
          onClick={() => setShowMenu((prev) => !prev)}
          style={{ position: "relative" }}
        />
        {showMenu && <Menu items={items} documentPage={true} />}
        <UploadFolder
          isOpen={isOpen}
          handleCloseModal={() => setIsOpen(false)}
          folderId={folderData?.id}
        />
        <UploadFile
          isOpen={isFileOpen}
          handleCloseModal={() => setIsFileOpen(false)}
          folderId={folderData?.id}
        />
      </div>
    </div>
  );
};

export default Documentation;
