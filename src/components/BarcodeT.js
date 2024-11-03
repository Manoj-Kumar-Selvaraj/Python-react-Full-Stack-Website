import React, { useEffect, useState, useRef } from 'react';
import './BarcodeFetch.css';

const BarcodeTTable = ({ token }) => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [tableVisible, setTableVisible] = useState(false);
  const [filters, setFilters] = useState({});
  const [selectedRowId, setSelectedRowId] = useState(null);
  const [editableRowData, setEditableRowData] = useState({});
  const [originalRowData, setOriginalRowData] = useState({}); // To keep track of original values

  const tableRef = useRef(null);
  const resizingRef = useRef({ column: null, startX: 0, startWidth: 0 });
  const tableContainerRef = useRef(null);

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
    if (selectedRowId === id) {
      setSelectedRowId(null);
      setEditableRowData({});
      setOriginalRowData({});
    } else {
      setSelectedRowId(id);
      const rowData = data.find(item => item.id === id);
      setEditableRowData(rowData); // Load row data for editing
      setOriginalRowData(rowData); // Keep track of original values
    }
  };

  const handleClickOutside = (event) => {
    if (tableContainerRef.current && !tableContainerRef.current.contains(event.target)) {
      setSelectedRowId(null); // Deselect if clicking outside the table
    }
  };

  useEffect(() => {
    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setEditableRowData((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleBlur = () => {
    // If no change made, revert to original data
    setEditableRowData(originalRowData);
  };

  const handleSubmit = async () => {
    try {
      const response = await fetch(`https://api.manoj-techworks.site/factoryoutlet/barcode/barcode_log/${selectedRowId}/`, {
        method: 'PUT',
        headers: {
          'Authorization': `Token ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(editableRowData),
      });

      if (response.ok) {
        const updatedData = await response.json();
        setData((prev) => prev.map(item => (item.id === selectedRowId ? updatedData : item)));
        setSelectedRowId(null); // Deselect after submission
        setEditableRowData({}); // Clear editable data
        setOriginalRowData({}); // Clear original data
      } else {
        console.error('Failed to update the data', response);
      }
    } catch (error) {
      console.error('There was an error updating the data!', error);
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
            <table ref={tableRef} className="data-table">
              <thead>
                <tr>
                  {[
                    'id',
                    'number_of_barcodes',
                    'start_barcode',
                    'last_barcode',
                    'print_status',
                    'dog',
                    'print_slot',
                    'gen_slot',
                    'Approval',
                    'b_type',
                    'eid',
                  ].map((column) => (
                    <th
                      key={column}
                      data-column={column}
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
                        onMouseDown={(e) => startResize(e, column)} // Start resizing
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
                    {selectedRowId === item.id ? (
                      <>
                        <td>
                          <input type="text" name="id" value={editableRowData.id || ''} readOnly />
                        </td>
                        <td>
                          <input
                            type="number"
                            name="number_of_barcodes"
                            value={editableRowData.number_of_barcodes || ''}
                            onChange={handleInputChange}
                            onBlur={handleBlur} // Revert on blur
                          />
                        </td>
                        <td>
                          <input
                            type="text"
                            name="start_barcode"
                            value={editableRowData.start_barcode || ''}
                            onChange={handleInputChange}
                            onBlur={handleBlur} // Revert on blur
                          />
                        </td>
                        <td>
                          <input
                            type="text"
                            name="last_barcode"
                            value={editableRowData.last_barcode || ''}
                            onChange={handleInputChange}
                            onBlur={handleBlur} // Revert on blur
                          />
                        </td>
                        <td>
                          <input
                            type="text"
                            name="print_status"
                            value={editableRowData.print_status || ''}
                            onChange={handleInputChange}
                            onBlur={handleBlur} // Revert on blur
                          />
                        </td>
                        <td>
                          <input
                            type="text"
                            name="dog"
                            value={editableRowData.dog || ''}
                            onChange={handleInputChange}
                            onBlur={handleBlur} // Revert on blur
                          />
                        </td>
                        <td>
                          <input
                            type="text"
                            name="print_slot"
                            value={editableRowData.print_slot || ''}
                            onChange={handleInputChange}
                            onBlur={handleBlur} // Revert on blur
                          />
                        </td>
                        <td>
                          <input
                            type="text"
                            name="gen_slot"
                            value={editableRowData.gen_slot || ''}
                            onChange={handleInputChange}
                            onBlur={handleBlur} // Revert on blur
                          />
                        </td>
                        <td>
                          <input
                            type="text"
                            name="Approval"
                            value={editableRowData.Approval || ''}
                            onChange={handleInputChange}
                            onBlur={handleBlur} // Revert on blur
                          />
                        </td>
                        <td>
                          <input
                            type="text"
                            name="b_type"
                            value={editableRowData.b_type || ''}
                            onChange={handleInputChange}
                            onBlur={handleBlur} // Revert on blur
                          />
                        </td>
                        <td>
                          <input
                            type="text"
                            name="eid"
                            value={editableRowData.eid || ''}
                            onChange={handleInputChange}
                            onBlur={handleBlur} // Revert on blur
                          />
                        </td>
                      </>
                    ) : (
                      <>
                        <td>{item.id}</td>
                        <td>{item.number_of_barcodes}</td>
                        <td>{item.start_barcode}</td>
                        <td>{item.last_barcode}</td>
                        <td>{item.print_status}</td>
                        <td>{item.dog}</td>
                        <td>{item.print_slot}</td>
                        <td>{item.gen_slot}</td>
                        <td>{item.Approval}</td>
                        <td>{item.b_type}</td>
                        <td>{item.eid}</td>
                      </>
                    )}
                  </tr>
                ))}
              </tbody>
            </table>
          )}
          {selectedRowId && (
            <button onClick={handleSubmit} className="submit-button">
              Submit Changes
            </button>
          )}
        </div>
      )}
    </div>
  );
};

export default BarcodeTTable;
