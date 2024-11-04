import React, { useEffect, useState, useRef } from 'react';
import './BarcodeFetch.css';

const BarcodeTTable = ({ token }) => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [tableVisible, setTableVisible] = useState(false);
  const [filters, setFilters] = useState({});
  const [selectedRowId, setSelectedRowId] = useState(null);
  const [columnWidths, setColumnWidths] = useState({
    id: 100,
    number_of_barcodes: 150,
    start_barcode: 120,
    last_barcode: 120,
    print_status: 100,
    dog: 80,
    print_slot: 100,
    gen_slot: 100,
    Approval: 100,
    b_type: 100,
    eid: 100,
  });

  const tableRef = useRef(null);
  const resizingRef = useRef({ column: null, startX: 0, startWidth: 0 });
  const tableContainerRef = useRef(null);
  const [editedData, setEditedData] = useState({});

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

  const handleToggleTable = () => {
    setTableVisible(!tableVisible);
    if (!tableVisible && data.length === 0) {
      BarcodeTFetch();
    }
  };

  const getUniqueValues = (column) => [...new Set(data.map((item) => item[column]))];

  const handleFilterChange = (e, column) => {
    setFilters({
      ...filters,
      [column]: e.target.value,
    });
  };

  const filteredData = data.filter((item) =>
    Object.entries(filters).every(
      ([column, value]) => !value || item[column].toString() === value
    )
  );

  const startResize = (e, column) => {
    e.preventDefault();
    resizingRef.current.column = column;
    resizingRef.current.startX = e.clientX;
    resizingRef.current.startWidth = tableRef.current.querySelector(`th[data-column="${column}"]`).offsetWidth;

    document.addEventListener('mousemove', doDrag);
    document.addEventListener('mouseup', stopResize);
  };

  const doDrag = (e) => {
    if (resizingRef.current.column) {
      const newWidth = Math.max(resizingRef.current.startWidth + (e.clientX - resizingRef.current.startX), 50);
      const column = resizingRef.current.column;

      const header = tableRef.current.querySelector(`th[data-column="${column}"]`);
      header.style.width = `${newWidth}px`;

      const cells = tableRef.current.querySelectorAll(`td:nth-child(${Array.from(header.parentNode.children).indexOf(header) + 1})`);
      cells.forEach(cell => {
        cell.style.width = `${newWidth}px`;
      });
    }
  };

  const stopResize = () => {
    resizingRef.current.column = null;
    document.removeEventListener('mousemove', doDrag);
    document.removeEventListener('mouseup', stopResize);
  };

  const handleRowClick = (id) => {
    setSelectedRowId(id === selectedRowId ? null : id);
  };

  const handleClickOutside = (event) => {
    if (tableContainerRef.current && !tableContainerRef.current.contains(event.target)) {
      setSelectedRowId(null);
    }
  };

  useEffect(() => {
    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  const handleChange = (e, id, column) => {
    const value = e.target.value;
    setEditedData((prev) => ({
      ...prev,
      [id]: {
        ...prev[id],
        [column]: value,  // Always update to the latest entered value, including empty strings
      },
    }));
  };

  const handleSubmit = async () => {
    // Create an array to hold the updated records
    const updatedData = Object.entries(editedData).map(([id, values]) => {
      // Find the original record based on the ID
      const originalRecord = data.find(item => item.id === Number(id));
      
      // Merge original data with updated values
      return {
        ...originalRecord, // Spread the original record
        ...values,         // Override with edited values
      };
    });

    try {
      const response = await fetch('https://api.manoj-techworks.site/factoryoutlet/barcode/barcode_log/', {
        method: 'POST',
        headers: {
          'Authorization': `Token ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(updatedData), // Send merged data
      });

      if (!response.ok) {
        throw new Error('Failed to update data');
      }

      const result = await response.json();
      console.log('Updated Records:', result);
      // Optionally, refresh your data
      BarcodeTFetch();
      setEditedData({}); // Clear edited data after submission
    } catch (error) {
      console.error("Error updating data:", error);
    }
  };

  return (
    <div>
      <h1>Barcode History</h1>
      <button className="toggle-button" onClick={handleToggleTable}>
        {tableVisible ? 'Hide Table' : 'Show Table'}
      </button>

      {tableVisible && (
        <div className="table-container" ref={tableContainerRef}>
          {loading ? (
            <p>Loading data...</p>
          ) : (
            <>
              <table ref={tableRef} className="data-table">
                <thead>
                  <tr>
                    {Object.keys(columnWidths).map((column) => (
                      <th
                        key={column}
                        data-column={column}
                        style={{ width: columnWidths[column] }}
                      >
                        <div className="header-container">
                          {column.replace('_', ' ').toUpperCase()}
                          <select
                            className="filter-select"
                            onChange={(e) => handleFilterChange(e, column)}
                            value={filters[column] || ''}
                          >
                            <option value="">All</option>
                            {getUniqueValues(column).map((val) => (
                              <option key={val} value={val}>
                                {val}
                              </option>
                            ))}
                          </select>
                        </div>
                        <div
                          className="resizer"
                          onMouseDown={(e) => startResize(e, column)}
                        />
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {filteredData.map((item) => (
                    <tr
                      key={item.id}
                      onClick={() => handleRowClick(item.id)}
                      className={selectedRowId === item.id ? 'selected' : ''}
                    >
                      <td style={{ width: columnWidths.id }}>{item.id}</td>
                      {Object.keys(columnWidths).slice(1).map(column => (
                        <td key={column} style={{ width: columnWidths[column] }}>
                          <input
                            type="text"
                            value={editedData[item.id]?.[column] ?? item[column]}  // Display edited value or fallback to fetched data
                            onChange={(e) => handleChange(e, item.id, column)}
                            placeholder={item[column]} // Show placeholder when input is empty
                            readOnly={!['print_slot', 'gen_slot', 'Approval'].includes(column)}
                          />
                        </td>
                      ))}
                    </tr>
                  ))}
                </tbody>
              </table>
              <button onClick={handleSubmit}>Submit Changes</button>
            </>
          )}
        </div>
      )}
    </div>
  );
};

export default BarcodeTTable;
