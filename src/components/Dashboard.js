import React from 'react';
import BarcodeTTable from './BarcodeT';
import EmployeeTTable from './EmployeeT';
import ProductsTable from './ProductsT';
import TypeTable from './TypeT';

const Dashboard = ({ token }) => {
  return (
    <>
      <BarcodeTTable token={token} />
      <EmployeeTTable token={token} />
      <ProductsTable token={token} />
    </>
  );
};

export default Dashboard;
