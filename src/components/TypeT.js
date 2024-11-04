import React, { useEffect, useState, useRef } from 'react';
import * as XLSX from 'xlsx'; // Import the xlsx library
import './BarcodeFetch.css'; // Ensure this contains styles for loading spinner and table

const TypeDataTable = ({ token }) => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [filters, setFilters] = useState({});
  const [selectedRowId, setSelectedRowId] = useState(null);
  const [columnWidths, setColumnWidths] = useState({
    b_type: 100,
    psize: 100,
    pname: 150,
    ptype: 100,
    pseller: 150,
    last_processed_date: 120,
    last_barcode: 150,
    pamount: 100,
    eid: 100,
  });

  const tableRef = useRef(null);
  const resizingRef = useRef({ column: null, startX: 0, startWidth: 0 });
  const tableContainerRef = useRef(null);

  const fetchTypeData = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await fetch('https://api.manoj-techworks.site/factoryoutlet/type-select/type-records/', {
        method: 'GET',
        headers: {
          'Authorization': `Token ${token}`,
        },
      });
      if (!response.ok) throw new Error('Network response was not ok');
      const fetchedData = await response.json();
      console.log(fetchedData);  // Debugging: Check response structure
      setData(Array.isArray(fetchedData) ? fetchedData : []);
    } catch (error) {
      console.error("There was an error fetching the data!", error);
      setError("Failed to fetch data. Please try again later.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
      fetchTypeData();
  }, [token]);

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

  const handleDownload = () => {
    // Create a new workbook
    const wb = XLSX.utils.book_new();
    // Convert filtered data into a worksheet
    const ws = XLSX.utils.json_to_sheet(filteredData);
    // Append the worksheet to the workbook
    XLSX.utils.book_append_sheet(wb, ws, "Type Data");
    // Trigger the download
    XLSX.writeFile(wb, "TypeData.xlsx");
  };

  useEffect(() => {
    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  return (
    <div>
        <div className="table-container" ref={tableContainerRef}>
          {loading ? (
            <p>Loading data...</p>
          ) : error ? (
            <p>{error}</p>
          ) : (
            <div>
              <button className="download-button" onClick={handleDownload}>
                Download as Excel
              </button>
              <table ref={tableRef} className="data-table">
                <thead>
                  <tr>
                    {[
                      'b_type',
                      'psize',
                      'pname',
                      'ptype',
                      'pseller',
                      'last_processed_date',
                      'last_barcode',
                      'pamount',
                      'eid',
                    ].map((column) => (
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
                      key={item.last_barcode} // Ensure this is unique across the dataset
                      onClick={() => handleRowClick(item.last_barcode)}
                      className={selectedRowId === item.last_barcode ? 'selected' : ''}
                    >
                      <td style={{ width: columnWidths.b_type }}>{item.b_type}</td>
                      <td style={{ width: columnWidths.psize }}>{item.psize}</td>
                      <td style={{ width: columnWidths.pname }}>{item.pname}</td>
                      <td style={{ width: columnWidths.ptype }}>{item.ptype}</td>
                      <td style={{ width: columnWidths.pseller }}>{item.pseller}</td>
                      <td style={{ width: columnWidths.last_processed_date }}>{item.last_processed_date}</td>
                      <td style={{ width: columnWidths.last_barcode }}>{item.last_barcode}</td>
                      <td style={{ width: columnWidths.pamount }}>{item.pamount}</td>
                      <td style={{ width: columnWidths.eid }}>{item.eid}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
    </div>
  );
};

export default TypeDataTable;
