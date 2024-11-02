import React, { useEffect, useState, useRef } from 'react';
import './BarcodeFetch.css';

const BarcodeTTable = ({ token }) => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [tableVisible, setTableVisible] = useState(false);
  const [filters, setFilters] = useState({});
  const [selectedRowId, setSelectedRowId] = useState(null); // Add state for selected row
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
    setSelectedRowId(id === selectedRowId ? null : id); // Toggle selection
  };

  return (
    <div>
      <h1 className="heading">Barcode History</h1>
      <button className="toggle-button" onClick={handleToggleTable}>
        {tableVisible ? 'Hide Table' : 'Show Table'}
      </button>
      <div className="divider"></div> {/* Visual divider */}
      {tableVisible && (
        <div className="table-container">
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
                      style={{ width: columnWidths[column] }} // Initial width
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
                    onClick={() => handleRowClick(item.id)} // Add onClick handler to each row
                    className={selectedRowId === item.id ? 'selected' : ''} // Apply selected class
                  >
                    <td style={{ width: columnWidths.id }}>{item.id}</td>
                    <td style={{ width: columnWidths.number_of_barcodes }}>{item.number_of_barcodes}</td>
                    <td style={{ width: columnWidths.start_barcode }}>{item.start_barcode}</td>
                    <td style={{ width: columnWidths.last_barcode }}>{item.last_barcode}</td>
                    <td style={{ width: columnWidths.print_status }}>{item.print_status}</td>
                    <td style={{ width: columnWidths.dog }}>{item.dog}</td>
                    <td style={{ width: columnWidths.print_slot }}>{item.print_slot}</td>
                    <td style={{ width: columnWidths.gen_slot }}>{item.gen_slot}</td>
                    <td style={{ width: columnWidths.Approval }}>{item.Approval}</td>
                    <td style={{ width: columnWidths.b_type }}>{item.b_type}</td>
                    <td style={{ width: columnWidths.eid }}>{item.eid}</td>
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
