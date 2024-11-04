import React, { useEffect, useState, useRef } from 'react';
import './BarcodeFetch.css';
import * as XLSX from 'xlsx'; // Import the xlsx library

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
      if (!response.ok) {
        throw new Error('Failed to fetch data');
      }
      const fetchedData = await response.json();
      setData(fetchedData);
    } catch (error) {
      alert("There was an error fetching the data!");
      console.error("Fetch error:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
      BarcodeTFetch();
    },[token]);

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
        [column]: value,
      },
    }));
  };

  const handleSubmit = async () => {
    const updatedData = Object.entries(editedData).map(([id, values]) => ({
      id: Number(id),
      ...values,
    }));

    try {
      const response = await fetch('https://api.manoj-techworks.site/factoryoutlet/barcode/barcode_log/', {
        method: 'POST',
        headers: {
          'Authorization': `Token ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(updatedData),
      });

      if (!response.ok) {
        throw new Error('Failed to update data');
      }

      const result = await response.json();
      alert("Data updated successfully!");
      BarcodeTFetch(); // Refresh the data
      setEditedData({});
    } catch (error) {
      alert("Error updating data. Please try again.");
      console.error("Update error:", error);
    }
  };

  // Function to download table as Excel
  const exportToExcel = () => {
    const ws = XLSX.utils.json_to_sheet(filteredData); // Convert filtered data to a worksheet
    const wb = XLSX.utils.book_new(); // Create a new workbook
    XLSX.utils.book_append_sheet(wb, ws, 'Barcode Data'); // Append worksheet to the workbook
    XLSX.writeFile(wb, 'barcode_data.xlsx'); // Download the workbook
  };

  return (
    <div>
        <div className="table-container" ref={tableContainerRef}>
          {loading ? (
            <p>Loading data...</p>
          ) : (
            <>
              <button onClick={exportToExcel}>Download as Excel</button> {/* Button to download Excel */}
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
                          {['print_slot', 'gen_slot'].includes(column) ? (
                            <select
                              value={editedData[item.id]?.[column] ?? item[column]}
                              onChange={(e) => handleChange(e, item.id, column)}
                            >
                              <option value="Y">Y</option>
                              <option value="N">N</option>
                            </select>
                          ) : column === 'Approval' ? (
                            <select
                              value={editedData[item.id]?.[column] ?? item[column]}
                              onChange={(e) => handleChange(e, item.id, column)}
                            >
                              <option value="A">A</option>
                              <option value="R">R</option>
                              <option value="C">C</option>
                            </select>
                          ) : (
                            <input
                              type="text"
                              value={editedData[item.id]?.[column] ?? item[column]}
                              onChange={(e) => handleChange(e, item.id, column)}
                            />
                          )}
                        </td>
                      ))}
                    </tr>
                  ))}
                </tbody>
              </table>
              <button onClick={handleSubmit}>Update</button>
            </>
          )}
        </div>
    </div>
  );
};

export default BarcodeTTable;
