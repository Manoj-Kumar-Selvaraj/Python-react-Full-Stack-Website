import React from 'react';
import BarcodeTTable from './BarcodeT'
function Dashboard({ token }) {
  return (
    <BarcodeTTable token={token}/>
    <EmployeeTTable token={token}/>
  );
}

export default Dashboard;
