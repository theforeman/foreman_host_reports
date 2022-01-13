import React from 'react';

import StatusCell from '../StatusCell';

const statusFormatter = () => (_, { rowData }) => {
  const statuses = {
    change: rowData.change,
    nochange: rowData.nochange,
    failure: rowData.failure,
  };
  return <StatusCell statuses={statuses} />;
};

export default statusFormatter;
