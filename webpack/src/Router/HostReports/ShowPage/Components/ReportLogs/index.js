import React from 'react';
import PropTypes from 'prop-types';

import PuppetLogs from './Puppet';
import AnsibleLogs from './Ansible';

const ReportLogs = ({ format, logs, meta }) => {
  switch (format) {
    case 'puppet':
      return <PuppetLogs logs={logs} environment={meta.environment} />;
    case 'ansible':
      return <AnsibleLogs logs={logs} checkMode={meta.checkMode} />;
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
