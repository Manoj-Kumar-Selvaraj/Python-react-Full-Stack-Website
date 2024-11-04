import React, { useState } from 'react';
import './Dashboard.css'; // Assuming you have CSS for styling

const Dashboard = ({ token }) => {
  const [activeTab, setActiveTab] = useState('products');

  const renderContent = () => {
    switch (activeTab) {
      case 'products':
        return <ProductsTable token={token} />;
      case 'barcodes':
        return <BarcodeTTable token={token} />;
      case 'employees':
        return <EmployeeTTable token={token} />;
      case 'types':
        return <TypeTable token={token} />;
      default:
        return <ProductsTable token={token} />;
    }
  };

  return (
    <div className="dashboard">
      <nav className="sidebar">
        <button onClick={() => setActiveTab('products')} className={activeTab === 'products' ? 'active' : ''}>
          Products
        </button>
        <button onClick={() => setActiveTab('barcodes')} className={activeTab === 'barcodes' ? 'active' : ''}>
          Barcodes
        </button>
        <button onClick={() => setActiveTab('employees')} className={activeTab === 'employees' ? 'active' : ''}>
          Employees
        </button>
        <button onClick={() => setActiveTab('types')} className={activeTab === 'types' ? 'active' : ''}>
          Types
        </button>
      </nav>
      <div className="tab-content">
        {renderContent()}
      </div>
    </div>
  );
};

export default Dashboard;
