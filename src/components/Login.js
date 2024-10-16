import React, { useState } from 'react';
import { Helmet } from 'react-helmet';
import icon from './login.jpg';
import logo from './factoryoutlet_icon.jpeg';
import './Login.css';
function Login({ onLoginSuccess }) {
  const [eid, setEid] = useState('');
  const [password, setPassword] = useState('');

  const handleLogin = async () => {
    try {
      const response = await fetch('https://api.manoj-techworks.site/factoryoutlet/auth/auth-token/', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ eid, password }),
      });

      if (response.ok) {
        const data = await response.json();
        console.log('Token:', data.token); // Print the token to the console
        localStorage.setItem('authToken', data.token); // Store the token
        onLoginSuccess(data.token); // Pass the token to the parent component
      } else {
        const errorData = await response.json();
        alert('Login failed: ' + (errorData.error || 'Invalid credentials'));
      }
    } catch (error) {
      console.error('Login error:', error);
      alert('Login failed');
    }
  };

  return (
    <div>
      <div className='logo'>
        <Helmet>
          <title>Login</title>
          <link rel="icon" href={icon} />
        </Helmet>
        <h2>FactoryOutlet</h2>
        <div className='logo'>
          <img src={logo} alt='Icon'>
          </img>
        </div>
      </div>
      <div className='Login'>
        <input
          type="text"
          value={eid}
          onChange={(e) => setEid(e.target.value)}
          placeholder="Employee ID"
        />
        <input
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="Password"
        />
        <button onClick={handleLogin}>Login</button>
      </div>
    </div>  
  );
}

export default Login;
