import React, { useEffect, useState } from 'react';
import { useTable, useFilters } from 'react-table';
import './BarcodeFetch.css';

const BarcodeTTable = ({ token }) => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);

  const BarcodeTFetch = async () => {
    setLoading(true);
    try {
      const response = await fetch('https://api.manoj-techworks.site/factoryoutlet/barcode/barcode_log/', {
        method: 'GET',
        headers: {
          Authorization: `Token ${token}`,
        },
      });

      if (!response.ok) throw new Error("Network response was not ok");
      const responseData = await response.json();
      setData(responseData);
    } catch (error) {
      console.error("There was an error fetching the data!", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    BarcodeTFetch();
  }, []);

  function DefaultColumnFilter({
    column: { filterValue, setFilter, Header },
  }) {
    return (
      <input
        value={filterValue || ''}
        onChange={(e) => setFilter(e.target.value || undefined)}
        placeholder={`Filter ${Header}`}
        className="filter-input"
      />
    );
  }

  const columns = React.useMemo(
    () => [
      { Header: 'ID', accessor: 'id', Filter: DefaultColumnFilter },
      { Header: 'Number of Barcodes', accessor: 'number_of_barcodes', Filter: DefaultColumnFilter },
      { Header: 'Start Barcode', accessor: 'start_barcode', Filter: DefaultColumnFilter },
      { Header: 'Last Barcode', accessor: 'last_barcode', Filter: DefaultColumnFilter },
      { Header: 'Print Status', accessor: 'print_status', Filter: DefaultColumnFilter },
      { Header: 'Date of Generation (DOG)', accessor: 'dog', Filter: DefaultColumnFilter },
      { Header: 'Print Slot', accessor: 'print_slot', Filter: DefaultColumnFilter },
      { Header: 'Generation Slot', accessor: 'gen_slot', Filter: DefaultColumnFilter },
      { Header: 'Approval', accessor: 'Approval', Filter: DefaultColumnFilter },
      { Header: 'Barcode Type', accessor: 'b_type', Filter: DefaultColumnFilter },
      { Header: 'Employee ID', accessor: 'eid', Filter: DefaultColumnFilter },
    ],
    []
  );

  const defaultColumn = React.useMemo(
    () => ({
      Filter: DefaultColumnFilter,
    }),
    []
  );

  const tableInstance = useTable({ columns, data, defaultColumn }, useFilters);

  const {
    getTableProps,
    getTableBodyProps,
    headerGroups,
    rows,
    prepareRow,
  } = tableInstance;

  return (
    <div>
      <h1>Barcode Data Table</h1>
      {loading ? (
        <p>Loading data...</p>
      ) : (
        <table {...getTableProps()} className="data-table">
          <thead>
            {headerGroups.map(headerGroup => (
              <tr {...headerGroup.getHeaderGroupProps()}>
                {headerGroup.headers.map(column => (
                  <th {...column.getHeaderProps()}>
                    {column.render('Header')}
                    <div>{column.canFilter ? column.render('Filter') : null}</div>
                  </th>
                ))}
              </tr>
            ))}
          </thead>
          <tbody {...getTableBodyProps()}>
            {rows.map(row => {
              prepareRow(row);
              return (
                <tr {...row.getRowProps()}>
                  {row.cells.map(cell => (
                    <td {...cell.getCellProps()}>{cell.render('Cell')}</td>
                  ))}
                </tr>
              );
            })}
          </tbody>
        </table>
      )}
    </div>
  );
};

export default BarcodeTTable;
