import React, { useEffect, useState, useRef } from 'react';
import * as XLSX from 'xlsx';  // Import the xlsx library
import './BarcodeFetch.css';

const ProductsTable = ({ token }) => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [filters, setFilters] = useState({});
  const [selectedRowId, setSelectedRowId] = useState(null);
  const [columnWidths, setColumnWidths] = useState({
    pid: 100,
    pname: 150,
    pseller: 150,
    psize: 100,
    dop: 120,
    dos: 120,
    pamount: 100,
    eid: 100,
    bar_code: 150,
    bamount: 100,
    status: 50,
  });

  const tableRef = useRef(null);
  const resizingRef = useRef({ column: null, startX: 0, startWidth: 0 });
  const tableContainerRef = useRef(null);

  const fetchProductsData = async () => {
    setLoading(true);
    try {
      const response = await fetch('https://api.manoj-techworks.site/factoryoutlet/products/select-products/', {
        method: 'GET',
        headers: {
          'Authorization': `Token ${token}`,
        },
      });
      const fetchedData = await response.json();
      console.log(fetchedData);  // Debugging: Check response structure

      setData(Array.isArray(fetchedData.data) ? fetchedData.data : []);
    } catch (error) {
      console.error("There was an error fetching the data!", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
      fetchProductsData();
    }, [token])

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

  // Function to handle Excel download
  const handleDownloadExcel = () => {
    const ws = XLSX.utils.json_to_sheet(filteredData); // Convert JSON data to a worksheet
    const wb = XLSX.utils.book_new(); // Create a new workbook
    XLSX.utils.book_append_sheet(wb, ws, 'Products'); // Append the worksheet to the workbook
    XLSX.writeFile(wb, 'products_data.xlsx'); // Trigger download
  };

  return (
    <div>
        <div className="table-container" ref={tableContainerRef}>
          {loading ? (
            <p>Loading data...</p>
          ) : (
            <div>
              <button className="download-button" onClick={handleDownloadExcel}>
                Download Excel
              </button>
              <table ref={tableRef} className="data-table">
                <thead>
                  <tr>
                    {[
                      'pid',
                      'pname',
                      'pseller',
                      'psize',
                      'dop',
                      'dos',
                      'pamount',
                      'eid',
                      'bar_code',
                      'bamount',
                      'status',
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
                      key={item.pid}
                      onClick={() => handleRowClick(item.pid)}
                      className={selectedRowId === item.pid ? 'selected' : ''}
                    >
                      <td style={{ width: columnWidths.pid }}>{item.pid}</td>
                      <td style={{ width: columnWidths.pname }}>{item.pname}</td>
                      <td style={{ width: columnWidths.pseller }}>{item.pseller}</td>
                      <td style={{ width: columnWidths.psize }}>{item.psize}</td>
                      <td style={{ width: columnWidths.dop }}>{item.dop}</td>
                      <td style={{ width: columnWidths.dos }}>{item.dos}</td>
                      <td style={{ width: columnWidths.pamount }}>{item.pamount}</td>
                      <td style={{ width: columnWidths.eid }}>{item.eid}</td>
                      <td style={{ width: columnWidths.bar_code }}>{item.bar_code}</td>
                      <td style={{ width: columnWidths.bamount }}>{item.bamount}</td>
                      <td style={{ width: columnWidths.status }}>{item.status}</td>
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

export default ProductsTable;
