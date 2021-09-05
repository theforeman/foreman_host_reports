import React from 'react';

import StatusCell from '../StatusCell';

const statusFormatter = () => (value, { rowData: { format, status } }) => (
  <StatusCell format={format} value={value} />
);

export default statusFormatter;
