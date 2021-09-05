import React from 'react';
import HostReportsToShowCell from '../HostReportsToShowCell';

const hostReportsToShowFormatter = () => (
  value,
  { rowData: { canEdit, hostId } }
) => (
  <HostReportsToShowCell active={canEdit} id={hostId}>
    {value}
  </HostReportsToShowCell>
);

export default hostReportsToShowFormatter;
