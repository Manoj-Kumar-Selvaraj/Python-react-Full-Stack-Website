import React, { useEffect, useState } from 'react';
import { useTable } from 'react-table';
import '.BarcodeTFetch.css'; // Basic CSS for styling

const BarcodeTTable = ({ token }) => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);

  // Asynchronous function to fetch data from the API using fetch
  const BarcodeTFetch = async () => {
    setLoading(true); // Set loading to true before the fetch
    try {
      const response = await fetch('https://api.manoj-techworks.site/factoryoutlet/barcode/barcode_log/', {
        method: 'GET',
        headers: {
          Authorization: `Token ${token}`,
        },
      });

      // Check if response is OK, then parse JSON
      if (!response.ok) throw new Error("Network response was not ok");

      const responseData = await response.json();
      setData(responseData); // Update data state with the fetched data
    } catch (error) {
      console.error("There was an error fetching the data!", error);
    } finally {
      setLoading(false); // Set loading to false after fetch is complete
    }
  };

  useEffect(() => {
    BarcodeTFetch();
  }, []);

  // Define columns for react-table
  const columns = React.useMemo(
    () => [
      {
        Header: 'ID',   // Replace with actual field names
        accessor: 'id', // Must match the JSON field name from Django
      },
      {
        Header: 'Name', // Replace with actual field name
        accessor: 'name',
      },
      {
        Header: 'Created Date', // Example field
        accessor: 'created_at',
      },
      // Add more columns as needed
    ],
    []
  );

  // Use react-table hook to manage table instance
  const tableInstance = useTable({ columns, data });

  // Destructure the table instance for easy access
  const {
    getTableProps,
    getTableBodyProps,
    headerGroups,
    rows,
    prepareRow,
  } = tableInstance;

  return (
    <div>
      <h1>Data Table</h1>
      {loading ? (
        <p>Loading data...</p>
      ) : (
        <table {...getTableProps()} className="data-table">
          <thead>
            {headerGroups.map(headerGroup => (
              <tr {...headerGroup.getHeaderGroupProps()}>
                {headerGroup.headers.map(column => (
                  <th {...column.getHeaderProps()}>{column.render('Header')}</th>
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
