import React from 'react';

import StatusCell from '../StatusCell';

const statusFormatter = () => (_, { rowData }) => {
  const statuses = {
    applied: rowData.applied,
    failed: rowData.failed,
    pending: rowData.pending,
    other: rowData.other,
  };
  return <StatusCell statuses={statuses} />;
};

export default statusFormatter;
