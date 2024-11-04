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
  const [optionsb, setOptionsb] = useState([]);
  const [loading, setLoading] = useState(true);

  // State for Type Delete
  const [psized, setPsized] = useState('');
  const [pnamed, setPnamed] = useState('');
  const [ptyped, setPtyped] = useState('');
  const [psellerd, setPsellerd] = useState('');
  const [pamountd, setPamountd] = useState('');

  const [filteredNames, setFilteredNames] = useState([]);
  const [filteredSizes, setFilteredSizes] = useState([]);
  const [filteredTypes, setFilteredTypes] = useState([]);
  const [filteredSellers, setFilteredSellers] = useState([]);
  const [filteredAmounts, setFilteredAmounts] = useState([]);

  const [filteredNamesb, setFilteredNamesb] = useState([]);
  const [filteredSizesb, setFilteredSizesb] = useState([]);
  const [filteredTypesb, setFilteredTypesb] = useState([]);
  const [filteredSellersb, setFilteredSellersb] = useState([]);
  const [filteredAmountsb, setFilteredAmountsb] = useState([]);

  // State for Employee Deactivate
  const [eidd, setEidd] = useState('');
  
  // State for dropdown selection flow control

  const [notificationb, setNotificationb] = useState('');
  const [firstSelectionb, setFirstSelectionb] = useState('');
  const [notificationd, setNotificationd] = useState('');
  const [firstSelectiond, setFirstSelectiond] = useState('');
  const [ProductNameb,setProductNameb] = useState('')
  const [Pnamed, setpnamed] = useState('')
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [activeTab, setActiveTab] = useState('generateBarcodes');
  const toggleSidebar = () => setSidebarOpen(!sidebarOpen);
  const handleTabClick = (tabId) => setActiveTab(tabId);

  
  // Define fetchOptions outside useEffect
  const fetchOptions = async () => {
    setLoading(true); // Set loading to true before the fetch
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
        setOptionsb(data); // Set the second state with the same data

        // Prepare options based on fetched data
        const optionArray = [];
        data.forEach((item, index) => { // Use fetched data here
          Object.keys(item).forEach((key) => {
            const value = item[key];
            optionArray.push(
              <option key={`${key}-${index}`} value={value}>
                {key}: {value}
              </option>
            );
          });
        });
        // Here you may want to set this optionArray somewhere if needed
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

  useEffect(() => {
    fetchOptions(); // Call fetchOptions on component mount
  }, []);

  const handleRefresh = async () => {
    await fetchOptions(); // Call fetchOptions to refresh data
    await resetEmployeeForm();
    await resetBarcodeForm();
    await resetEmployeeDeleteForm();
    await resetTypeTForm();
    await resetTypeTDeletionForm();
  };



useEffect(() => {
    if (productName) {
      // Filter and set unique values for each attribute based on productName
      const sizeOptions = [...new Set(optionsb.filter(option => option.pname === productName).map(option => option.psize))];
      const typeOptions = [...new Set(optionsb.filter(option => option.pname === productName).map(option => option.ptype))];
      const sellerOptions = [...new Set(optionsb.filter(option => option.pname === productName).map(option => option.pseller))];
      const amountOptions = [...new Set(optionsb.filter(option => option.pname === productName).map(option => option.pamount))];

      setFilteredSizesb(sizeOptions);
      setFilteredTypesb(typeOptions);
      setFilteredSellersb(sellerOptions);
      setFilteredAmountsb(amountOptions);
    } else {
      setFilteredSizesb([]);
      setFilteredTypesb([]);
      setFilteredSellersb([]);
      setFilteredAmountsb([]);
      }
  }, [productName, optionsb]);

  // Function to filter all dropdowns based on selected values
  useEffect(() => {
    if (pnamed) {
      const sizeOptions = options.filter(option => option.pname === pnamed).map(option => option.psize);
      setFilteredSizes([...new Set(sizeOptions)]); // Unique sizes
      
      const typeOptions = options.filter(option => option.pname === pnamed).map(option => option.ptype);
      setFilteredTypes([...new Set(typeOptions)]);

      const sellerOptions = options.filter(option => option.pname === pnamed).map(option => option.pseller);
      setFilteredSellers([...new Set(sellerOptions)]);

      const amountOptions = options.filter(option => option.pname === pnamed).map(option => option.pamount);
      setFilteredAmounts([...new Set(amountOptions)]);
    } else {
      setFilteredSizes([]);
      setFilteredTypes([]);
      setFilteredSellers([]);
      setFilteredAmounts([]);
    }
  }, [pnamed, options]);
  // Function to reset Barcode form
  const resetBarcodeForm = () => {
    setNumberOfBarcodes('');
    setProductName('');
    setProductSize('');
    setProductType('');
    setSeller('');
    setAmount('');
  };

  // Function to reset Employee forms
  const resetEmployeeForm = () => {
    setEid('');
    setEname('');
    setLastLogin('');
    setIsActive(true);
    setIsSuperuser(false);
  };
  const resetEmployeeDeleteForm = () => {
    setEidd('');
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
    setPsized('');
    setPnamed('');
    setPtyped('');
    setPsellerd('');
    setPamountd('');
  };

  const handleFlowb = (e) => {
    setProductNameb(DOMPurify.sanitize(e.target.value));
    setProductName(ProductNameb)
    if (!productName) {
      setNotificationb('Please select the Product Name.');
      return;
    }
  };

  const handleFlowd = (e) => {
    setpnamed(DOMPurify.sanitize(e.target.value));
    setPnamed(Pnamed)
    if (!setPnamed) {
      setNotificationd('Please select the Product Name.');
      return;
    }
  };
  // Function to handle TypeT form submission
const handleTypeTSubmit = async (e, action) => {
  e.preventDefault(); // Prevent the default form submission behavior

  // Define the URL based on the action
  let url = '';
  let typeTData = {};
    if (action === 'Add') {
      url = 'https://api.manoj-techworks.site/factoryoutlet/type/create-type/';
      typeTData = {
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
      typeTData = {
      psize: DOMPurify.sanitize(psized),
      pname: DOMPurify.sanitize(pnamed),
      ptype: DOMPurify.sanitize(ptyped),
      pseller: DOMPurify.sanitize(psellerd),
      pamount: parseFloat(DOMPurify.sanitize(pamountd)) 
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
    
    console.log(typeTData); // Log the data being sent

    if (!response.ok) {
      // Attempt to read error response
      const errorData = await response.json();
      console.error('Error code:', response.status); // Log the status code
      console.error('Error message:', errorData); // Log the error response
      alert(`Error: ${response.status} - ${errorData.message || 'An error occurred'}`);
      return; // Exit if an error occurs
    }
    
    const data = await response.json(); // Parse the response JSON
    alert(`${action} operation successful`);
    
    // Reset forms based on the action
    if (action === 'Add') {
      resetTypeTForm(); // Reset form only if it's an Add operation
    } else {
      resetTypeTDeletionForm();
    }
  } catch (error) {
    console.error('Error:', error); // Log the error
    alert('An error occurred: ' + error.message); // Display the error message to the user
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
        console.log(response)
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
        eid: DOMPurify.sanitize(eidd), // Only use eid for deactivation
        is_active: false, // Explicitly setting this, though it might be unnecessary for deactivation
      };
    }
  
    // Define the URL based on the action
    let url;
    if (action === 'Add') {
      url = 'https://api.manoj-techworks.site/factoryoutlet/employee/access/'; // URL for adding an employee
    } else if (action === 'Deactivate') {
      url = `https://api.manoj-techworks.site/factoryoutlet/emp-dea/access/`; // URL for deactivating an employee
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
    <div className="admin-container">
      {/* Sidebar Toggle Button */}
      <button onClick={toggleSidebar} className="sidebar-toggle">
        {sidebarOpen ? 'Close' : 'Menu'}
      </button>

      {/* Sidebar */}
      <nav className={`sidebar ${sidebarOpen ? 'open' : ''}`}>
        {['generateBarcodes', 'createEmployee', 'deactivateEmployee', 'addProductType', 'deleteProductType'].map(tab => (
          <button key={tab} onClick={() => handleTabClick(tab)}>
            {tab.replace(/([A-Z])/g, ' $1').replace(/^./, str => str.toUpperCase())}
          </button>
        ))}
      </nav>

      <button className="Refresh" onClick={handleRefresh}>Refresh Data</button>

      {/* Main Content */}
      {activeTab === 'generateBarcodes' && <GenerateBarcodesForm />}
      {activeTab === 'createEmployee' && <CreateEmployeeForm />}
      {activeTab === 'deactivateEmployee' && <DeactivateEmployeeForm />}
      {activeTab === 'addProductType' && <AddProductTypeForm />}
      {activeTab === 'deleteProductType' && <DeleteProductTypeForm />}
    </div>
  );
};

const GenerateBarcodesForm = () => {
  return (
    <form id="generateBarcodes" onSubmit={handleBarcodeSubmit} className="barcode-form">
      {loading && <LoadingOverlay />}

      <FormInput 
        label="Number of Barcodes (integer):"
        type="number"
        value={number_of_barcodes}
        onChange={e => setNumberOfBarcodes(DOMPurify.sanitize(e.target.value))}
        required
      />

      <FormSelect 
        label="Product Name:"
        value={productName}
        onChange={e => setProductName(DOMPurify.sanitize(e.target.value))}
        options={Array.from(new Set(optionsb.map(item => item.pname)))}
        required
      />

      <FormSelect 
        label="Product Size:"
        value={productSize}
        onChange={e => setProductSize(DOMPurify.sanitize(e.target.value))}
        options={filteredSizesb}
        required
      />

      <FormSelect 
        label="Product Type:"
        value={productType}
        onChange={e => setProductType(DOMPurify.sanitize(e.target.value))}
        options={filteredTypesb}
        required
      />

      <FormSelect 
        label="Product Seller:"
        value={seller}
        onChange={e => setSeller(DOMPurify.sanitize(e.target.value))}
        options={filteredSellersb}
        required
      />

      <FormSelect 
        label="Product Amount:"
        value={amount}
        onChange={e => setAmount(DOMPurify.sanitize(e.target.value))}
        options={filteredAmountsb}
        required
      />

      <button type="submit" className="btn">Generate Barcodes</button>
    </form>
  );
};

const CreateEmployeeForm = () => {
  return (
    <form id="createEmployee" onSubmit={event => handleEmployeeSubmit(event, "Add")} className="employee-form">
      {loading && <LoadingOverlay />}

      <FormInput 
        label="Employee ID:"
        type="text"
        value={eid}
        onChange={e => setEid(DOMPurify.sanitize(e.target.value))}
        required
      />
      
      <FormInput 
        label="Employee Name:"
        type="text"
        value={ename}
        onChange={e => setEname(DOMPurify.sanitize(e.target.value))}
        required
      />

      <FormInput 
        label="Last Login:"
        type="datetime-local"
        value={lastLogin}
        onChange={e => setLastLogin(DOMPurify.sanitize(e.target.value))}
      />

      <FormCheckbox 
        label="Is Active"
        checked={isActive}
        onChange={e => setIsActive(e.target.checked)}
      />

      <FormCheckbox 
        label="Is Superuser"
        checked={isSuperuser}
        onChange={e => setIsSuperuser(e.target.checked)}
      />

      <button type="submit" className="btn">Create Employee</button>
    </form>
  );
};

// Define the other forms similarly...

const LoadingOverlay = () => (
  <div className="loading-overlay">
    <div className="spinner"></div>
  </div>
);

const FormInput = ({ label, type, value, onChange, required }) => (
  <div className="form-group">
    <label>{label}</label>
    <input type={type} value={value} onChange={onChange} required={required} />
  </div>
);

const FormSelect = ({ label, value, onChange, options, required }) => (
  <div className="form-group">
    <label>{label}</label>
    <select value={value} onChange={onChange} required={required}>
      <option value="">Select an option</option>
      {options.map((option, index) => (
        <option key={index} value={option}>{option}</option>
      ))}
    </select>
  </div>
);

const FormCheckbox = ({ label, checked, onChange }) => (
  <div className="form-group">
    <label>
      <input type="checkbox" checked={checked} onChange={onChange} />
      {label}
    </label>
  </div>
);

export default AdminPanel;
