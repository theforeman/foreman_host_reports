import React from 'react';
import PropTypes from 'prop-types';

import PuppetLogs from './Puppet';

const ReportLogs = ({ format, logs, meta }) => {
  switch (format) {
    case 'puppet':
      return <PuppetLogs logs={logs} environment={meta.environment} />;
    default:
      return <></>;
  }
};

ReportLogs.propTypes = {
  format: PropTypes.string.isRequired,
  logs: PropTypes.array,
  meta: PropTypes.object,
};

ReportLogs.defaultProps = {
  logs: [],
  meta: {},
};

export default ReportLogs;
