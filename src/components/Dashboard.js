import React, { useState } from 'react'; // Import useState from React
import BarcodeTTable from './BarcodeT';
import EmployeeTTable from './EmployeeT';
import ProductsTable from './ProductsT';
import TypeTable from './TypeT';

const Dashboard = ({ token }) => {
  const [activeTab, setActiveTab] = useState('products');

  const renderActiveTab = () => {
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
    <>
      <nav className="tabs">
        <button
          onClick={() => setActiveTab('products')}
          className={activeTab === 'products' ? 'active' : 'inactive'}
        >
          Products
        </button>
        <button
          onClick={() => setActiveTab('barcodes')}
          className={activeTab === 'barcodes' ? 'active' : 'inactive'}
        >
          Barcodes
        </button>
        <button
          onClick={() => setActiveTab('employees')}
          className={activeTab === 'employees' ? 'active' : 'inactive'}
        >
          Employees
        </button>
        <button
          onClick={() => setActiveTab('types')}
          className={activeTab === 'types' ? 'active' : 'inactive'}
        >
          Types
        </button>
      </nav>
      <div className="tab-content">
        {renderActiveTab()}
      </div>
    </>
  );
};

export default Dashboard;
