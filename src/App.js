import React, { useState } from 'react';
import Home from './components/Home';
import Barcode from './components/Barcode';
import Billing from './components/Billing';
import Dashboard from './components/Dashboard';
import Admin from './components/Admin';
import Login from './components/Login';
import './App.css'; // Ensure you have this CSS file for styling

function App() {
  const [activeTab, setActiveTab] = useState('home');
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [token, setToken] = useState(null); // State to store the authentication token

  const renderTabContent = () => {
    if (!isAuthenticated) {
      return <Login onLoginSuccess={(token) => { 
        setIsAuthenticated(true); 
        setToken(token); // Store the token on successful login
      }} />;
    }

    switch (activeTab) {
      case 'home':
        return <Home />;
      case 'barcode':
        return <Barcode token={token} />;
      case 'billing':
        return <Billing />;
      case 'dashboard':
        return <Dashboard />;
      case 'admin':
        return <Admin />;
      default:
        return <Home />;
    }
  };

  return (
    <div>
      {isAuthenticated && (
        <nav className="tabs">
          <button onClick={() => setActiveTab('home')} className={activeTab === 'home' ? 'active' : ''}>
            Home
          </button>
          <button onClick={() => setActiveTab('barcode')} className={activeTab === 'barcode' ? 'active' : ''}>
            Barcode
          </button>
          <button onClick={() => setActiveTab('billing')} className={activeTab === 'billing' ? 'active' : ''}>
            Billing
          </button>
          <button onClick={() => setActiveTab('dashboard')} className={activeTab === 'dashboard' ? 'active' : ''}>
            Dashboard
          </button>
          <button onClick={() => setActiveTab('admin')} className={activeTab === 'admin' ? 'active' : ''}>
            Admin
          </button>
        </nav>
      )}
      <div className="tab-content">{renderTabContent()}</div>
    </div>
  );
}

export default App;
