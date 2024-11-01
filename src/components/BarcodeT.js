import React, { useEffect, useState } from 'react';
import './BarcodeFetch.css';

const BarcodeTTable = ({ token }) => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [tableVisible, setTableVisible] = useState(false);
  const [filters, setFilters] = useState({});

  // Fetch data from your Django API
  const BarcodeTFetch = async () => {
    setLoading(true);
    try {
      const response = await fetch('https://api.manoj-techworks.site/factoryoutlet/barcode/barcode_log/', {
        method: 'GET',
        headers: {
          'Authorization': `Token ${token}`,
        },
      });
      const jsonData = await response.json();
      setData(jsonData);
    } catch (error) {
      console.error("Error fetching data:", error);
    } finally {
      setLoading(false);
    }
  };

  // Load data when table is made visible
  useEffect(() => {
    if (tableVisible) {
      BarcodeTFetch();
    }
  }, [tableVisible]);

  // Toggle table visibility
  const toggleTable = () => {
    setTableVisible(!tableVisible);
  };

  // Handle filter change
  const handleFilterChange = (e, accessor) => {
    setFilters({ ...filters, [accessor]: e.target.value });
  };

  // Apply filter to data
  const filteredData = data.filter(row => {
    return Object.keys(filters).every(accessor => {
      return filters[accessor] ? String(row[accessor]).includes(filters[accessor]) : true;
    });
  });

  return (
    <div>
      <button className="toggle-button" onClick={toggleTable}>
        {tableVisible ? 'Hide Table' : 'Show Table'}
      </button>

      {tableVisible && (
        <div>
          <h1>Data Table</h1>
          {loading ? (
            <p>Loading data...</p>
          ) : (
            <table className="data-table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>
                    Number of Barcodes
                    <select onChange={(e) => handleFilterChange(e, 'number_of_barcodes')}>
                      <option value="">All</option>
                      {data.map(row => (
                        <option key={row.id} value={row.number_of_barcodes}>
                          {row.number_of_barcodes}
                        </option>
                      ))}
                    </select>
                  </th>
                  <th>
                    Start Barcode
                    <select onChange={(e) => handleFilterChange(e, 'start_barcode')}>
                      <option value="">All</option>
                      {data.map(row => (
                        <option key={row.id} value={row.start_barcode}>
                          {row.start_barcode}
                        </option>
                      ))}
                    </select>
                  </th>
                  <th>
                    Last Barcode
                    <select onChange={(e) => handleFilterChange(e, 'last_barcode')}>
                      <option value="">All</option>
                      {data.map(row => (
                        <option key={row.id} value={row.last_barcode}>
                          {row.last_barcode}
                        </option>
                      ))}
                    </select>
                  </th>
                  <th>
                    Print Status
                    <select onChange={(e) => handleFilterChange(e, 'print_status')}>
                      <option value="">All</option>
                      {data.map(row => (
                        <option key={row.id} value={row.print_status}>
                          {row.print_status}
                        </option>
                      ))}
                    </select>
                  </th>
                  <th>Other Fields...</th>
                  {/* Repeat for other fields as per your database structure */}
                </tr>
              </thead>
              <tbody>
                {filteredData.map(row => (
                  <tr key={row.id}>
                    <td>{row.id}</td>
                    <td>{row.number_of_barcodes}</td>
                    <td>{row.start_barcode}</td>
                    <td>{row.last_barcode}</td>
                    <td>{row.print_status}</td>
                    {/* Render other fields as per your database */}
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
