import React, { useEffect } from "react";
import { useNavigate } from "react-router-dom";

const ProtectedRoute = ({ element }) => {
  const navigate = useNavigate();

  useEffect(() => {
    // Check if user navigated through the app (if no navigation flag, redirect to /home)
    const isNavigatedThroughApp = sessionStorage.getItem('navigatedThroughApp');

    if (!isNavigatedThroughApp) {
      navigate("/home");  // Redirect to /home if accessed directly
    }
  }, [navigate]);

  return element;  // Render the component if navigated through the app
};

export default ProtectedRoute;
