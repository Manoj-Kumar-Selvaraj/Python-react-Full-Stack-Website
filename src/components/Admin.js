import React, { useState, useEffect } from 'react';
import DOMPurify from 'dompurify';

const Admin = () => {
  // State variables
  const [barcodeValue, setBarcodeValue] = useState('');
  const [employeeName, setEname] = useState('');
  const [lastLogin, setLastLogin] = useState('');
  const [isActive, setIsActive] = useState(false);
  const [isSuperuser, setIsSuperuser] = useState(false);
  const [psize, setPsize] = useState('');
  const [pname, setPname] = useState('');
  const [ptype, setPtype] = useState('');
  const [pseller, setPseller] = useState('');
  const [bType, setBType] = useState('');
  const [lastProcessedDate, setLastProcessedDate] = useState('');
  const [lastBarcode, setLastBarcode] = useState('');
  const [latPid, setLatPid] = useState('');
  const [pamount, setPamount] = useState('');
  
  // State for fetched dropdown options
  const [typeRecords, setTypeRecords] = useState([]);
  
  useEffect(() => {
    // Fetch type records from the API
    const fetchTypeRecords = async () => {
      try {
        const response = await fetch('https://api.manoj-techworks.site/factoryoutlet/type-select/type-records');
        const data = await response.json();
        setTypeRecords(data); // Assuming data is an array of objects
      } catch (error) {
        console.error('Error fetching type records:', error);
      }
    };
    
    fetchTypeRecords();
  }, []); // Empty dependency array to run only once when the component mounts

  // Reset forms
  const resetBarcodeForm = () => {
    setBarcodeValue('');
  };

  const resetEmployeeForm = () => {
    setEname('');
    setLastLogin('');
    setIsActive(false);
    setIsSuperuser(false);
  };

  const resetTypeTForm = () => {
    setPsize('');
    setPname('');
    setPtype('');
    setPseller('');
    setBType('');
    setLastProcessedDate('');
    setLastBarcode('');
    setLatPid('');
    setPamount('');
  };

  // Submit handlers
  const handleBarcodeSubmit = (e) => {
    e.preventDefault();
    // Handle barcode submission logic here
    resetBarcodeForm();
  };

  const handleEmployeeSubmit = (e) => {
    e.preventDefault();
    // Handle employee submission logic here
    resetEmployeeForm();
  };

  const handleTypeTSubmit = (e) => {
    e.preventDefault();
    // Handle TypeT submission logic here
    resetTypeTForm();
  };

  return (
    <div>
      {/* Barcode Generation Form */}
      <form onSubmit={handleBarcodeSubmit} className="barcode-form">
        <h2>Barcode Generation</h2>
        <div className="form-group">
          <label>Product Size:</label>
          <select value={psize} onChange={(e) => setPsize(e.target.value)} required>
            <option value="" disabled>Select Product Size</option>
            {typeRecords.map(record => (
              <option key={record.id} value={record.size}>
                {record.size}
              </option>
            ))}
          </select>
        </div>
        <div className="form-group">
          <label>Product Name:</label>
          <select value={pname} onChange={(e) => setPname(e.target.value)} required>
            <option value="" disabled>Select Product Name</option>
            {typeRecords.map(record => (
              <option key={record.id} value={record.name}>
                {record.name}
              </option>
            ))}
          </select>
        </div>
        <div className="form-group">
          <label>Product Type:</label>
          <select value={ptype} onChange={(e) => setPtype(e.target.value)} required>
            <option value="" disabled>Select Product Type</option>
            {typeRecords.map(record => (
              <option key={record.id} value={record.type}>
                {record.type}
              </option>
            ))}
          </select>
        </div>
        <div className="form-group">
          <label>Seller:</label>
          <select value={pseller} onChange={(e) => setPseller(e.target.value)} required>
            <option value="" disabled>Select Seller</option>
            {typeRecords.map(record => (
              <option key={record.id} value={record.seller}>
                {record.seller}
              </option>
            ))}
          </select>
        </div>
        <div className="form-group">
          <label>Type Re:</label>
          <select value={barcodeValue} onChange={(e) => setBarcodeValue(e.target.value)} required>
            <option value="" disabled>Select Type Record</option>
            {typeRecords.map(record => (
              <option key={record.id} value={record.id}>
                {record.amount} {/* Adjust according to your data structure */}
              </option>
            ))}
          </select>
        </div>
        <button type="submit" className="btn">Generate Barcode</button>
      </form>

      {/* Employee Form */}
      <form onSubmit={handleEmployeeSubmit} className="employee-form">
        <h2>Create Employee</h2>
        <div className="form-group">
          <label>Employee Name:</label>
          <input
            type="text"
            placeholder="Enter Employee Name"
            value={employeeName}
            onChange={(e) => setEname(DOMPurify.sanitize(e.target.value))}
            required
          />
        </div>
        <div className="form-group">
          <label>Last Login:</label>
          <input
            type="datetime-local"
            value={lastLogin}
            onChange={(e) => setLastLogin(DOMPurify.sanitize(e.target.value))}
          />
        </div>
        <div className="form-group">
          <label>
            <input
              type="checkbox"
              checked={isActive}
              onChange={(e) => setIsActive(e.target.checked)}
            />
            Is Active
          </label>
        </div>
        <div className="form-group">
          <label>
            <input
              type="checkbox"
              checked={isSuperuser}
              onChange={(e) => setIsSuperuser(e.target.checked)}
            />
            Is Superuser
          </label>
        </div>
        <button type="submit" className="btn">Create Employee</button>
      </form>

      {/* TypeT Form */}
      <form onSubmit={handleTypeTSubmit} className="typeT-form">
        <h2>Create TypeT</h2>
        <div className="form-group">
          <label>Product Size:</label>
          <select value={psize} onChange={(e) => setPsize(e.target.value)} required>
            <option value="" disabled>Select Product Size</option>
            {typeRecords.map(record => (
              <option key={record.id} value={record.size}>
                {record.size}
              </option>
            ))}
          </select>
        </div>
        <div className="form-group">
          <label>Product Name:</label>
          <select value={pname} onChange={(e) => setPname(e.target.value)} required>
            <option value="" disabled>Select Product Name</option>
            {typeRecords.map(record => (
              <option key={record.id} value={record.name}>
                {record.name}
              </option>
            ))}
          </select>
        </div>
        <div className="form-group">
          <label>Product Type:</label>
          <select value={ptype} onChange={(e) => setPtype(e.target.value)} required>
            <option value="" disabled>Select Product Type</option>
            {typeRecords.map(record => (
              <option key={record.id} value={record.type}>
                {record.type}
              </option>
            ))}
          </select>
        </div>
        <div className="form-group">
          <label>Seller:</label>
          <select value={pseller} onChange={(e) => setPseller(e.target.value)} required>
            <option value="" disabled>Select Seller</option>
            {typeRecords.map(record => (
              <option key={record.id} value={record.seller}>
                {record.seller}
              </option>
            ))}
          </select>
        </div>
        <div className="form-group">
          <label>Barcode Type:</label>
          <select value={bType} onChange={(e) => setBType(e.target.value)} required>
            <option value="" disabled>Select Barcode Type</option>
            {typeRecords.map(record => (
              <option key={record.id} value={record.barcodeType}>
                {record.barcodeType}
              </option>
            ))}
          </select>
        </div>
        <button type="submit" className="btn">Create TypeT</button>
      </form>
    </div>
  );
};

export default Admin;
