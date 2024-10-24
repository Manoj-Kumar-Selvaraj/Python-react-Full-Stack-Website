import React, { useState, useEffect } from 'react';
import DOMPurify from 'dompurify';
import './BarcodeForm.css'; // Import your CSS file

const Admin = ({ token }) => {
  // State for barcode form
  const [number_of_barcodes, setNumberOfBarcodes] = useState('');
  const [productName, setProductName] = useState('');
  const [productSize, setProductSize] = useState('');
  const [productType, setProductType] = useState('');
  const [seller, setSeller] = useState('');
  const [amount, setAmount] = useState('');

  // State for employee form
  const [eid, setEid] = useState('');
  const [ename, setEname] = useState('');
  const [lastLogin, setLastLogin] = useState('');
  const [isActive, setIsActive] = useState(true);
  const [isSuperuser, setIsSuperuser] = useState(false);

  // State for TypeT form
  const [psize, setPsize] = useState('');
  const [pname, setPname] = useState('');
  const [ptype, setPtype] = useState('');
  const [pseller, setPseller] = useState('');
  const [bType, setBType] = useState('');
  const [lastProcessedDate, setLastProcessedDate] = useState('');
  const [lastBarcode, setLastBarcode] = useState('');
  const [latPid, setLatPid] = useState('');
  const [pamount, setPamount] = useState('');
  const [options, setOptions] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchOptions = async () => {
      try {
        const response = await fetch('https://api.manoj-techworks.site/factoryoutlet/type-select/type-records/', {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Token ${token}`,
          },
        });

        const data = await response.json();
        if (response.ok) {
          setOptions(data); // Set the fetched options
          // Prepare options based on fetched data
          const optionArray = [];
          const FilteredName = [];
          options.forEach((item, index) => {
            // Loop through each key in the object
            Object.keys(item).forEach((key) => {
              const value = item[key];
              optionArray.push(
                <option key={`${key}-${index}`} value={value}>
                {key}: {value}
                </option>
                );
              });
            });
          
        } else {
          alert('Error fetching options: ' + JSON.stringify(data));
        }
      } catch (error) {
        console.error('Error fetching options:', error);
        alert('An error occurred while fetching options');
      } finally {
        setLoading(false); // Set loading to false once data is fetched
      }
    };

    fetchOptions();
  }, [token]);



  // Function to reset Barcode form
  const resetBarcodeForm = () => {
    setNumberOfBarcodes('');
    setProductName('');
    setProductSize('');
    setProductType('');
    setSeller('');
    setAmount('');
  };

  // Function to reset Employee form
  const resetEmployeeForm = () => {
    setEid('');
    setEname('');
    setLastLogin('');
    setIsActive(true);
    setIsSuperuser(false);
  };
  const resetEmployeeDeleteForm = () => {
    setEid('');
  };

  // Function to reset TypeT form
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

  const resetTypeTDeletionForm = () => {
    setPsize('');
    setPname('');
    setPtype('');
    setPseller('');
    setPamount('');
  };
  // Function to handle TypeT form submission
  const handleTypeTSubmit = async (e, action) => {
    e.preventDefault(); // Prevent the default form submission behavior
  
    // Define the URL based on the action
    let url = '';
    let typeTData = {}
    
    if (action === 'Add') {
      url = 'https://api.manoj-techworks.site/factoryoutlet/type/create-type/';
      const typeTData = {
      psize: DOMPurify.sanitize(psize),
      pname: DOMPurify.sanitize(pname),
      ptype: DOMPurify.sanitize(ptype),
      pseller: DOMPurify.sanitize(pseller),
      b_type: DOMPurify.sanitize(bType),
      last_processed_date: lastProcessedDate ? DOMPurify.sanitize(lastProcessedDate) : null, // Optional field
      last_barcode: lastBarcode ? parseInt(DOMPurify.sanitize(lastBarcode)) : 0, // Optional field
      lat_pid: latPid ? parseInt(DOMPurify.sanitize(latPid)) : null, // Optional field
      pamount: parseFloat(DOMPurify.sanitize(pamount)) 
    };
    } else if (action === 'Delete') {
      url = 'https://api.manoj-techworks.site/factoryoutlet/type-delete/delete-type/';
      const typeTData = {
      psize: DOMPurify.sanitize(psize),
      pname: DOMPurify.sanitize(pname),
      ptype: DOMPurify.sanitize(ptype),
      pseller: DOMPurify.sanitize(pseller),
      pamount: parseFloat(DOMPurify.sanitize(pamount)) 
    };
    }
  
    try {
      const response = await fetch(url, {
        method: 'POST', // Use POST for both operations
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Token ${token}`, // Include your token if required
        },
        body: JSON.stringify(typeTData) // Send the body data
      });
  
      const data = await response.json();
      if (response.ok) {
        alert(`${action} operation successful`);
        if (action === 'Add') {
          resetTypeTForm(); // Reset form only if it's an Add operation
        }
        else {
          resetTypeTDeletionForm();
        }
      } else {
        alert('Error: ' + JSON.stringify(data));
      }
    } catch (error) {
      console.error('Error:', error);
      alert('An error occurred');
    }
  };
  

  // Function to handle barcode form submission
  const handleBarcodeSubmit = async (e) => {
    e.preventDefault();

    const barcodeData = {
      number_of_barcodes: parseInt(DOMPurify.sanitize(number_of_barcodes)),  // Sanitize and convert to int
      'Product Name': DOMPurify.sanitize(productName),
      'Product Size': DOMPurify.sanitize(productSize),
      'Product Type': DOMPurify.sanitize(productType),
      Seller: DOMPurify.sanitize(seller),
      Amount: parseFloat(DOMPurify.sanitize(amount)),  // Sanitize and convert to float
    };

    try {
      const response = await fetch('https://api.manoj-techworks.site/factoryoutlet/barcode/generate-barcode/', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Token ${token}`,
        },
        body: JSON.stringify(barcodeData),
      });

      const data = await response.json();
      if (response.ok) {
        alert('Barcode generation successful');
        resetBarcodeForm(); // Reset Barcode form after successful submission
      } else {
        alert('Error: ' + JSON.stringify(data));
      }
    } catch (error) {
      console.error('Error:', error);
      alert('An error occurred');
    }
  };

  // Function to handle employee form submission
  const handleEmployeeSubmit = async (e, action) => {
    e.preventDefault(); // Prevent default form submission
  
    // Prepare employee data for the request
    let employeeData;
  
    if (action === 'Add') {
      employeeData = {
        eid: DOMPurify.sanitize(eid),
        ename: DOMPurify.sanitize(ename),
        last_login: lastLogin ? DOMPurify.sanitize(lastLogin) : null,  // Optional field
        is_active: isActive,
        is_superuser: isSuperuser,
      };
    } else if (action === 'Deactivate') {
      employeeData = {
        eid: DOMPurify.sanitize(eid), // Only use eid for deactivation
        is_active: false, // Explicitly setting this, though it might be unnecessary for deactivation
      };
    }
  
    // Define the URL based on the action
    let url;
    if (action === 'Add') {
      url = 'https://api.manoj-techworks.site/factoryoutlet/employee/access/'; // URL for adding an employee
    } else if (action === 'Deactivate') {
      url = `https://api.manoj-techworks.site/factoryoutlet/employee/deactivate/`; // URL for deactivating an employee
    }
  
    try {
      const response = await fetch(url, {
        method: 'POST', // Use POST for both actions
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Token ${token}`,
        },
        body: JSON.stringify(employeeData), // Send employeeData for both actions
      });
  
      const data = await response.json();
      if (response.ok) {
        alert(action === 'Deactivate' ? 'Employee deactivated successfully' : 'Employee creation successful');
        if (action === 'Add') {
          resetEmployeeForm(); // Reset Employee form after successful submission for Add action
        }
        else {
          resetEmployeeDeleteForm();
        }
      } else {
        alert('Error: ' + JSON.stringify(data));
      }
    } catch (error) {
      console.error('Error:', error);
      alert('An error occurred');
    }
  };
  

  return (
    <div>
      <h1>Admin Panel</h1>

      {/* Barcode Generation Form */}
      <form onSubmit={handleBarcodeSubmit} className="barcode-form">
        <h2 className="Heading">Generate Barcodes</h2>
        <div className="form-group">
          <label>Number of Barcodes (integer):</label>
          <input
            type="number"
            placeholder="Enter number of barcodes"
            value={number_of_barcodes}
            onChange={(e) => setNumberOfBarcodes(DOMPurify.sanitize(e.target.value))}
            required
          />
        </div>
        <div className="form-group">
          <label>Product Name:</label>
          <select
            value={productName}
            onChange={(e) => setProductName(DOMPurify.sanitize(e.target.value))}
            required
          >
                <option value="">Select a product name</option>
                {options
                  .filter(item => item.pname) // Assuming you want to filter by pname
                  .map((item, index) => (
                    <option key={index} value={item.pname}>
                      {item.pname}
                    </option>
                    ))
                }
          </select>
        </div>
        <div className="form-group">
          <label>Product Size:</label>
          <select
            value={productSize}
            onChange={(e) => setProductSize(DOMPurify.sanitize(e.target.value))}
            required
          >
                <option value="">Select a product size</option>
                {options
                  .filter(item => item.psize) // Assuming you want to filter by pname
                  .map((item, index) => (
                    <option key={index} value={item.psize}>
                      {item.psize}
                    </option>
                    ))
                }
          </select>
        </div>
        <div className="form-group">
          <label>Product Type:</label>
          <select
            value={productType}
            onChange={(e) => setProductType(DOMPurify.sanitize(e.target.value))}
            required
          >
                <option value="">Select a product type</option>
                {options
                  .filter(item => item.ptype) // Assuming you want to filter by pname
                  .map((item, index) => (
                    <option key={index} value={item.ptype}>
                      {item.ptype}
                    </option>
                    ))
                }
          </select>
        </div>
        <div className="form-group">
          <label>Product Seller:</label>
          <select
            value={seller}
            onChange={(e) => setSeller(DOMPurify.sanitize(e.target.value))}
            required
          >
                <option value="">Select a product seller</option>
                {options
                  .filter(item => item.pseller) // Assuming you want to filter by pname
                  .map((item, index) => (
                    <option key={index} value={item.pseller}>
                      {item.pseller}
                    </option>
                    ))
                }
          </select>
        </div>
        <div className="form-group">
          <label>Product Amount:</label>
          <select
            value={amount}
            onChange={(e) => setAmount(DOMPurify.sanitize(e.target.value))}
            required
          >
                <option value="">Select a product amount</option>
                {options
                  .filter(item => item.pamount) // Assuming you want to filter by pname
                  .map((item, index) => (
                    <option key={index} value={item.pamount}>
                      {item.pamount}
                    </option>
                    ))
                }
          </select>
        </div>
        <button type="submit" className="btn">Generate Barcodes</button>
      </form>

      {/* Employee Creation Form */}
      <form onSubmit={(event) => handleEmployeeSubmit(event,"Add")} className="employee-form">
        <h2 className="Heading">Create Employee</h2>
        <div className="form-group">
          <label>Employee ID:</label>
          <input
            type="text"
            placeholder="Enter Employee ID"
            value={eid}
            onChange={(e) => setEid(DOMPurify.sanitize(e.target.value))}
            required
          />
        </div>
        <div className="form-group">
          <label>Employee Name:</label>
          <input
            type="text"
            placeholder="Enter Employee Name"
            value={ename}
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
      {/* Employee Deletion Form */}
      <form onSubmit={(event) => handleEmployeeSubmit(event,"Deactivate")} className="employee-Deactivate">
        <h2 className="Heading">Deactivate Employee</h2>
        <div className="form-group">
          <label>Employee ID:</label>
          <input
            type="text"
            placeholder="Enter Employee ID"
            value={eid}
            onChange={(e) => setEid(DOMPurify.sanitize(e.target.value))}
            required
          />
        </div>

        <button type="submit" className="btn">Create Employee</button>
      </form>

      {/* TypeT Form */}
      <form onSubmit={(event) => handleTypeTSubmit(event, "Add")} className="typeT-delete">
        <h2 className="Heading">Add Product Type</h2>
        <div className="form-group">
          <label>Product Size:</label>
          <input
            type="text"
            placeholder="Enter product size"
            value={psize}
            onChange={(e) => setPsize(DOMPurify.sanitize(e.target.value))}
            required
          />
        </div>
        <div className="form-group">
          <label>Product Name:</label>
          <input
            type="text"
            placeholder="Enter product name"
            value={pname}
            onChange={(e) => setPname(DOMPurify.sanitize(e.target.value))}
            required
          />
        </div>
        <div className="form-group">
          <label>Product Type:</label>
          <input
            type="text"
            placeholder="Enter product type"
            value={ptype}
            onChange={(e) => setPtype(DOMPurify.sanitize(e.target.value))}
            required
          />
        </div>
        <div className="form-group">
          <label>Seller:</label>
          <input
            type="text"
            placeholder="Enter seller name"
            value={pseller}
            onChange={(e) => setPseller(DOMPurify.sanitize(e.target.value))}
            required
          />
        </div>
        <div className="form-group">
          <label>Barcode Type:</label>
          <input
            type="text"
            placeholder="Enter barcode type"
            value={bType}
            onChange={(e) => setBType(DOMPurify.sanitize(e.target.value))}
            required
          />
        </div>
        <div className="form-group">
          <label>Last Processed Date:</label>
          <input
            type="datetime-local"
            value={lastProcessedDate}
            onChange={(e) => setLastProcessedDate(DOMPurify.sanitize(e.target.value))}
          />
        </div>
        <div className="form-group">
          <label>Last Barcode:</label>
          <input
            type="number"
            placeholder="Enter last barcode"
            value={lastBarcode}
            onChange={(e) => setLastBarcode(DOMPurify.sanitize(e.target.value))}
          />
        </div>
        <div className="form-group">
          <label>Last Product ID:</label>
          <input
            type="number"
            placeholder="Enter last product ID"
            value={latPid}
            onChange={(e) => setLatPid(DOMPurify.sanitize(e.target.value))}
          />
        </div>
        <div className="form-group">
          <label>Product Amount:</label>
          <input
            type="number"
            step="0.01"
            placeholder="Enter product amount"
            value={pamount}
            onChange={(e) => setPamount(DOMPurify.sanitize(e.target.value))}
            required
          />
        </div>
        <button type="submit" className="btn">Create TypeT</button>
      </form>
      {/* TypeT Deletion Form */}
      <form onSubmit={(event) => handleTypeTSubmit(event, "Delete")} className="typeT-form">
        <h2 className="Heading">Delete Product Type</h2>
        <div className="form-group">
          <label>Product Name:</label>
          <select
            value={productName}
            onChange={(e) => setProductName(DOMPurify.sanitize(e.target.value))}
            required
          >
                <option value="">Select a product name</option>
                {options
                  .filter(item => item.pname) // Assuming you want to filter by pname
                  .map((item, index) => (
                    <option key={index} value={item.pname}>
                      {item.pname}
                    </option>
                    ))
                }
          </select>
        </div>
        <div className="form-group">
          <label>Product Size:</label>
          <select
            value={productSize}
            onChange={(e) => setProductSize(DOMPurify.sanitize(e.target.value))}
            required
          >
                <option value="">Select a product size</option>
                {options
                  .filter(item => item.psize) // Assuming you want to filter by pname
                  .map((item, index) => (
                    <option key={index} value={item.psize}>
                      {item.psize}
                    </option>
                    ))
                }
          </select>
        </div>
        <div className="form-group">
          <label>Product Type:</label>
          <select
            value={productType}
            onChange={(e) => setProductType(DOMPurify.sanitize(e.target.value))}
            required
          >
                <option value="">Select a product type</option>
                {options
                  .filter(item => item.ptype) // Assuming you want to filter by pname
                  .map((item, index) => (
                    <option key={index} value={item.ptype}>
                      {item.ptype}
                    </option>
                    ))
                }
          </select>
        </div>
        <div className="form-group">
          <label>Product Seller:</label>
          <select
            value={seller}
            onChange={(e) => setSeller(DOMPurify.sanitize(e.target.value))}
            required
          >
                <option value="">Select a product seller</option>
                {options
                  .filter(item => item.pseller) // Assuming you want to filter by pname
                  .map((item, index) => (
                    <option key={index} value={item.pseller}>
                      {item.pseller}
                    </option>
                    ))
                }
          </select>
        </div>
        <div className="form-group">
          <label>Product Amount:</label>
          <select
            value={amount}
            onChange={(e) => setAmount(DOMPurify.sanitize(e.target.value))}
            required
          >
                <option value="">Select a product amount</option>
                {options
                  .filter(item => item.pamount) // Assuming you want to filter by pname
                  .map((item, index) => (
                    <option key={index} value={item.pamount}>
                      {item.pamount}
                    </option>
                    ))
                }
          </select>
        </div>
        <button type="submit" className="btn">DELETE TYPE</button>
      </form>
    </div>
  );
};

export default Admin;

