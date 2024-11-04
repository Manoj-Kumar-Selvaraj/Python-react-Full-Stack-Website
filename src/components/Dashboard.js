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
      case 'admin':
        return <TypeTable token={token} />;
      default:
        return <ProductsTable token={token} />;
    }
  };

  return (
    <>      
    </>
  );
};

export default Dashboard;
