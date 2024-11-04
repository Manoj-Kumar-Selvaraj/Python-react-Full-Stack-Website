import React, { useEffect, useState, useRef } from 'react';
import * as XLSX from 'xlsx'; // Import the xlsx library
import './BarcodeFetch.css';

const EmployeeTable = ({ token }) => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [filters, setFilters] = useState({});
  const [selectedRowId, setSelectedRowId] = useState(null);
  const [columnWidths, setColumnWidths] = useState({
    eid: 100,
    ename: 150,
    last_login: 150,
    is_active: 100,
    is_superuser: 100,
    created_at: 150,
    updated_at: 150,
  });

  const tableRef = useRef(null);
  const resizingRef = useRef({ column: null, startX: 0, startWidth: 0 });
  const tableContainerRef = useRef(null);

  const fetchEmployeeData = async () => {
    setLoading(true);
    try {
      const response = await fetch('https://api.manoj-techworks.site/factoryoutlet/employee/select/', {
        method: 'GET',
        headers: {
          'Authorization': `Token ${token}`,
        },
      });
      const fetchedData = await response.json();
      console.log(fetchedData); // Debugging: Check response structure

      setData(Array.isArray(fetchedData.data) ? fetchedData.data : []);
    } catch (error) {
      console.error("There was an error fetching the data!", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect() => {
      fetchEmployeeData();
    },[ ])

  const getUniqueValues = (column) => [...new Set(data.map((item) => item[column]))];

  const handleFilterChange = (e, column) => {
    setFilters({
      ...filters,
      [column]: e.target.value,
    });
  };

  const filteredData = Array.isArray(data)
    ? data.filter((item) =>
        Object.entries(filters).every(
          ([column, value]) => !value || item[column].toString() === value
        )
      )
    : [];

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

  const exportToExcel = () => {
    const worksheet = XLSX.utils.json_to_sheet(filteredData); // Convert filtered data to a worksheet
    const workbook = XLSX.utils.book_new(); // Create a new workbook
    XLSX.utils.book_append_sheet(workbook, worksheet, "Employees"); // Append the worksheet to the workbook

    // Export the workbook to an Excel file
    XLSX.writeFile(workbook, "employee_data.xlsx");
  };

  return (
    <div>
        <div className="table-container" ref={tableContainerRef}>
          <button className="export-button" onClick={exportToExcel}>
            Download as Excel
          </button>
          {loading ? (
            <p>Loading data...</p>
          ) : (
            <table ref={tableRef} className="data-table">
              <thead>
                <tr>
                  {[
                    'eid',
                    'ename',
                    'last_login',
                    'is_active',
                    'is_superuser',
                    'created_at',
                    'updated_at',
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
                    key={item.eid}
                    onClick={() => handleRowClick(item.eid)}
                    className={selectedRowId === item.eid ? 'selected' : ''}
                  >
                    <td style={{ width: columnWidths.eid }}>{item.eid}</td>
                    <td style={{ width: columnWidths.ename }}>{item.ename}</td>
                    <td style={{ width: columnWidths.last_login }}>{item.last_login}</td>
                    <td style={{ width: columnWidths.is_active }}>{item.is_active ? 'Yes' : 'No'}</td>
                    <td style={{ width: columnWidths.is_superuser }}>{item.is_superuser ? 'Yes' : 'No'}</td>
                    <td style={{ width: columnWidths.created_at }}>{item.created_at}</td>
                    <td style={{ width: columnWidths.updated_at }}>{item.updated_at}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
    </div>
  );
};

export default EmployeeTable;
