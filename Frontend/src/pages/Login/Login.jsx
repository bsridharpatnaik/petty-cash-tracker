import React, { useEffect, useState } from "react";
import logo from "../../assets/png/logo.png";
import "./login.css";
import { ReactComponent as Lock } from "../../assets/svgs/Frame.svg";
import { ReactComponent as Hidden } from "../../assets/svgs/Group.svg";
import { ReactComponent as Left } from "../../assets/svgs/arrowleft.svg";
import { ReactComponent as Profile } from "../../assets/svgs/Profile.svg";
import { toast } from "react-toastify";
import { useNavigate } from "react-router-dom";

function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [passwordShown, setPasswordShown] = useState(false);
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();
  

  


  const togglePasswordVisibility = () => {
    setPasswordShown(!passwordShown);
  };



  const handleSubmit = async (event) => {
    event.preventDefault();
    setLoading(true);

    const loginData = {
      username: email,
      password: password,
    };

    try {
      const response = await fetch(`${process.env.REACT_APP_BASE_URL}/auth/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(loginData),
      });

      if (response.ok) {
        const data = await response.json();
        localStorage.setItem("user",JSON.stringify(data))

        navigate("/dashboard",{state : {isProgrammatic:true}})
        // Handle successful login, e.g., redirect to dashboard
      } else {
       toast.error("Bad Credentials")
        // Handle login failure, e.g., show error message
      }
    } catch (error) {
      console.error('Error occurred during login', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-container">
      <div className="wrapper_login">
        <Left onClick={() => navigate("/dashboard")} />
        <img src={logo} alt="Logo" className="login-logo" />
      </div>
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          justifyContent: "start",
          marginRight: "59px",
        }}
      >
        <h2>Login Account</h2>
        <p>Please login with your registered account.</p>
      </div>

      <div className="input-group">
        <label>Username</label>
        <div className="input-wrapper">
          <Profile />
          <input
            type="email"
            placeholder="Enter Username"
            style={{ color: "black" }}
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            autoComplete="off"
          />
        </div>
      </div>

      <div className="input-group">
        <label>Password</label>
        <div className="input-wrapper">
          <Lock />
          <input
            type={passwordShown ? "text" : "password"}
            placeholder="Enter your password"
            style={{ color: "black" }}
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            autoComplete="new-password"
          />
          <Hidden />
        </div>
      </div>

      <button
        className="login-button"
        onClick={handleSubmit}
        disabled={loading}
      >
        {loading ? <div className="loader"></div> : "Sign In"}
      </button>
    </div>
  );
}

export default Login;
