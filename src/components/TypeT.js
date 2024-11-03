import React, { useEffect, useState, useRef } from 'react';
import './BarcodeFetch.css';

const ProductsTable = ({ token }) => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [tableVisible, setTableVisible] = useState(false);
  const [filters, setFilters] = useState({});
  const [selectedRowId, setSelectedRowId] = useState(null);
  const [columnWidths, setColumnWidths] = useState({
    b_type: 100,
    pname: 150,
    ptype: 150,
    pseller: 150,
    psize: 100,
    last_processed_date: 120,
    last_barcode: 120,
    eid: 100,
    lat_pid: 100,
    pamount: 100,
  });

  const tableRef = useRef(null);
  const resizingRef = useRef({ column: null, startX: 0, startWidth: 0 });
  const tableContainerRef = useRef(null);

  const fetchProductsData = async () => {
    setLoading(true);
    try {
      const response = await fetch('https://api.manoj-techworks.site/factoryoutlet/type-select/type-records/', {
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

  const handleToggleTable = () => {
    setTableVisible(!tableVisible);
    if (!tableVisible && data.length === 0) {
      fetchProductsData();
    }
  };

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

  return (
    <div>
      <h1>Products Data</h1>
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
                    'b_type',
                    'pname',
                    'ptype',
                    'pseller',
                    'psize',
                    'last_processed_date',
                    'last_barcode',
                    'eid',
                    'lat_pid',
                    'pamount',
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
                    key={item.b_type} // Changed from item.pid to item.b_type
                    onClick={() => handleRowClick(item.b_type)} // Changed from item.pid to item.b_type
                    className={selectedRowId === item.b_type ? 'selected' : ''}
                  >
                    <td style={{ width: columnWidths.b_type }}>{item.b_type}</td>
                    <td style={{ width: columnWidths.pname }}>{item.pname}</td>
                    <td style={{ width: columnWidths.ptype }}>{item.ptype}</td>
                    <td style={{ width: columnWidths.pseller }}>{item.pseller}</td>
                    <td style={{ width: columnWidths.psize }}>{item.psize}</td>
                    <td style={{ width: columnWidths.last_processed_date }}>{item.last_processed_date}</td>
                    <td style={{ width: columnWidths.last_barcode }}>{item.last_barcode}</td>
                    <td style={{ width: columnWidths.eid }}>{item.eid}</td>
                    <td style={{ width: columnWidths.lat_pid }}>{item.lat_pid}</td>
                    <td style={{ width: columnWidths.pamount }}>{item.pamount}</td>
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

export default ProductsTable;
