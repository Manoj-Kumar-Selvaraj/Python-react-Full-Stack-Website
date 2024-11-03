import React from 'react';
import BarcodeTTable from './BarcodeTTable';
import EmployeeTTable from './EmployeeTTable';

const Dashboard = ({ token }) => {
  return (
    <>
      <BarcodeTTable token={token} />
      <EmployeeTTable token={token} />
    </>
  );
};

export default Dashboard;
