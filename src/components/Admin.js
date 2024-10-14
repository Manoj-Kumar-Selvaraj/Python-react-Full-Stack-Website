import React from 'react';
import React, { useState } from 'react';
import DOMPurify from 'dompurify';
import './BarcodeForm.css'; // Import your CSS file

const Admin = ({ token }) => {
  const [number_of_barcodes, setNumberOfBarcodes] = useState('');
  const [productName, setProductName] = useState('');
  const [productSize, setProductSize] = useState('');
  const [productType, setProductType] = useState('');
  const [seller, setSeller] = useState('');
  const [amount, setAmount] = useState('');

  const handleSubmit = async (e) => {
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
          'Authorization': `Token ${token}`, // Pass the token here
        },
        body: JSON.stringify(barcodeData),
      });

      const data = await response.json();
      if (response.ok) {
        alert('Barcode generation successful');
      } else {
        alert('Error: ' + JSON.stringify(data));
      }
    } catch (error) {
      console.error('Error:', error);
      alert('An error occurred');
    }
  };

  return (
    <form onSubmit={handleSubmit} className="barcode-form">
      <div className="form-group">
        <label>Number of Barcodes (integer):</label>
        <input type="number" placeholder="Enter number of barcodes" value={number_of_barcodes} onChange={(e) => setNumberOfBarcodes(DOMPurify.sanitize(e.target.value))} required />
      </div>
      <div className="form-group">
        <label>Product Name:</label>
        <input type="text" placeholder="Enter product name" value={productName} onChange={(e) => setProductName(DOMPurify.sanitize(e.target.value))} required />
      </div>
      <div className="form-group">
        <label>Product Size:</label>
        <input type="text" placeholder="Enter product size" value={productSize} onChange={(e) => setProductSize(DOMPurify.sanitize(e.target.value))} required />
      </div>
      <div className="form-group">
        <label>Product Type:</label>
        <input type="text" placeholder="Enter product type" value={productType} onChange={(e) => setProductType(DOMPurify.sanitize(e.target.value))} required />
      </div>
      <div className="form-group">
        <label>Seller:</label>
        <input type="text" placeholder="Enter seller name" value={seller} onChange={(e) => setSeller(DOMPurify.sanitize(e.target.value))} required />
      </div>
      <div className="form-group">
        <label>Amount (float):</label>
        <input type="number" step="0.01" placeholder="Enter amount" value={amount} onChange={(e) => setAmount(DOMPurify.sanitize(e.target.value))} required />
      </div>
      <button type="submit" className="btn">Generate Barcodes</button>
    </form>
  );
};

export default Admin;
