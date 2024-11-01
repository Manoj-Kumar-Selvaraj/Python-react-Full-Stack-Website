import React, { useEffect, useState } from 'react';
import './BarcodeFetch.css'; // Make sure to style accordingly

const BarcodeTTable = ({ token }) => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false); // Set to false initially
  const [tableVisible, setTableVisible] = useState(false); // Control table visibility
  const [filters, setFilters] = useState({}); // For dropdown filters

  const BarcodeTFetch = async () => {
    setLoading(true);
    try {
      const response = await fetch('https://api.manoj-techworks.site/factoryoutlet/barcode/barcode_log/', {
        method: 'GET',
        headers: {
          'Authorization': `Token ${token}`,
        },
      });
      const fetchedData = await response.json();
      setData(fetchedData);
    } catch (error) {
      console.error("There was an error fetching the data!", error);
    } finally {
      setLoading(false);
    }
  };

  // Toggle table display and load data on first click
  const handleToggleTable = () => {
    setTableVisible(!tableVisible);
    if (!tableVisible && data.length === 0) {
      BarcodeTFetch();
    }
  };

  // Unique values for dropdown filters
  const getUniqueValues = (column) => [...new Set(data.map((item) => item[column]))];

  // Handle filter changes
  const handleFilterChange = (e, column) => {
    setFilters({
      ...filters,
      [column]: e.target.value,
    });
  };

  // Apply filters to data
  const filteredData = data.filter((item) =>
    Object.entries(filters).every(
      ([column, value]) => !value || item[column].toString() === value
    )
  );

  return (
    <div>
      <h1>Data Table</h1>
      <button className="toggle-button" onClick={handleToggleTable}>
        {tableVisible ? 'Hide Table' : 'Show Table'}
      </button>

      {tableVisible && (
        <div>
          {loading ? (
            <p>Loading data...</p> // Loading message while fetching data
          ) : (
            <table className="data-table">
              <thead>
                <tr>
                  {/* Render filter dropdowns in the header */}
                  <th>
                    ID
                    <select
                      onChange={(e) => handleFilterChange(e, 'id')}
                      value={filters['id'] || ''}
                    >
                      <option value="">All</option>
                      {getUniqueValues('id').map((val) => (
                        <option key={val} value={val}>
                          {val}
                        </option>
                      ))}
                    </select>
                  </th>
                  <th>
                    Number of Barcodes
                    <select
                      onChange={(e) => handleFilterChange(e, 'number_of_barcodes')}
                      value={filters['number_of_barcodes'] || ''}
                    >
                      <option value="">All</option>
                      {getUniqueValues('number_of_barcodes').map((val) => (
                        <option key={val} value={val}>
                          {val}
                        </option>
                      ))}
                    </select>
                  </th>
                  <th>
                    Start Barcode
                    <select
                      onChange={(e) => handleFilterChange(e, 'start_barcode')}
                      value={filters['start_barcode'] || ''}
                    >
                      <option value="">All</option>
                      {getUniqueValues('start_barcode').map((val) => (
                        <option key={val} value={val}>
                          {val}
                        </option>
                      ))}
                    </select>
                  </th>
                  {/* Add other columns similarly */}
                </tr>
              </thead>
              <tbody>
                {filteredData.map((item) => (
                  <tr key={item.id}>
                    <td>{item.id}</td>
                    <td>{item.number_of_barcodes}</td>
                    <td>{item.start_barcode}</td>
                    {/* Render other columns similarly */}
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      )}
    </div>
  );
};

export default BarcodeTTable;
