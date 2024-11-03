import React from 'react';
import BarcodeTTable from './BarcodeT';
import EmployeeTTable from './EmployeeT';

const Dashboard = ({ token }) => {
  return (
    <>
      <BarcodeTTable token={token} />
      <EmployeeTTable token={token} />
    </>
  );
};

export default Dashboard;
