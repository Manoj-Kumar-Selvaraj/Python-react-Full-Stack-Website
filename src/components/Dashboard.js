import React from 'react';
import BarcodeTTable from './BarcodeT';
import EmployeeTTable from './EmployeeT';
import ProductsTable from './ProductsT';
import TypeTable from './TypeT';

const Dashboard = ({ token }) => {
  const [activeTab, setActiveTab] = useState('home');

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
          <button onClick={() => setActiveTab('products')} className={activeTab === 'products' ? 'active' : ''}>
            Sales
          </button>
          <button onClick={() => setActiveTab('barcodes')} className={activeTab === 'barcodes' ? 'active' : ''}>
            Barcodes
          </button>
          <button onClick={() => setActiveTab('employees')} className={activeTab === 'employees' ? 'active' : ''}>
            Employees
          </button>
          <button onClick={() => setActiveTab('types')} className={activeTab === 'types' ? 'active' : ''}>
            Products
          </button>
    </nav>
    </>
  );
};

export default Dashboard;
