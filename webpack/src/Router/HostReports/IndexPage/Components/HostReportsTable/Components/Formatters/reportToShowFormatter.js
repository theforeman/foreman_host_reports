import React from 'react';

import RelativeDateTime from 'foremanReact/components/common/dates/RelativeDateTime';

import ReportToShowCell from '../ReportToShowCell';

const reportToShowFormatter = () => (value, { rowData: { canEdit, id } }) => (
  <ReportToShowCell active={canEdit} id={id}>
    <RelativeDateTime date={value} />
  </ReportToShowCell>
);

export default reportToShowFormatter;
