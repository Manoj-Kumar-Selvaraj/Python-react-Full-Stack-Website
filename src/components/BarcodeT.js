import React, { useEffect, useState, useRef } from 'react';
import './BarcodeFetch.css';

const BarcodeTTable = ({ token }) => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [tableVisible, setTableVisible] = useState(false);
  const [filters, setFilters] = useState({});
  const [selectedRowId, setSelectedRowId] = useState(null);
  const [editedData, setEditedData] = useState({});

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
    setEditedData(prev => ({
      ...prev,
      [id]: {
        ...prev[id],
        [column]: value // Allow empty input to set fresh value
      },
    }));
  };

  const handleBlur = (id, column, value) => {
    // If no value entered, revert to original value
    if (!editedData[id] || !editedData[id][column]) {
      setEditedData(prev => ({
        ...prev,
        [id]: {
          ...prev[id],
          [column]: value // Restore original value
        },
      }));
    }
  };

  const handleSubmit = async () => {
    const updatedData = Object.entries(editedData).map(([id, values]) => ({
      id: Number(id), // Ensure ID is a number
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
                    <th data-column="print_slot">PRINT SLOT</th>
                    <th data-column="gen_slot">GEN SLOT</th>
                    <th data-column="Approval">APPROVAL</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredData.map((item) => (
                    <tr
                      key={item.id}
                      onClick={() => handleRowClick(item.id)}
                      className={selectedRowId === item.id ? 'selected' : ''}
                    >
                      <td>
                        <input
                          type="text"
                          value={editedData[item.id]?.print_slot || item.print_slot}
                          onChange={(e) => handleChange(e, item.id, 'print_slot')}
                          onBlur={() => handleBlur(item.id, 'print_slot', item.print_slot)} // Handle blur event
                          placeholder={item.print_slot} // Show placeholder when input is empty
                        />
                      </td>
                      <td>
                        <input
                          type="text"
                          value={editedData[item.id]?.gen_slot || item.gen_slot}
                          onChange={(e) => handleChange(e, item.id, 'gen_slot')}
                          onBlur={() => handleBlur(item.id, 'gen_slot', item.gen_slot)} // Handle blur event
                          placeholder={item.gen_slot} // Show placeholder when input is empty
                        />
                      </td>
                      <td>
                        <input
                          type="text"
                          value={editedData[item.id]?.Approval || item.Approval}
                          onChange={(e) => handleChange(e, item.id, 'Approval')}
                          onBlur={() => handleBlur(item.id, 'Approval', item.Approval)} // Handle blur event
                          placeholder={item.Approval} // Show placeholder when input is empty
                        />
                      </td>
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
