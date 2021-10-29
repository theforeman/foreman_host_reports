import React from 'react';
import PropTypes from 'prop-types';

import PuppetLogs from './Puppet';
import AnsibleLogs from './Ansible';

const ReportLogs = ({ format, logs, meta, onFilterClear }) => {
  switch (format) {
    case 'puppet':
      return <PuppetLogs logs={logs} onClear={onFilterClear} />;
    case 'ansible':
      return (
        <AnsibleLogs
          logs={logs}
          checkMode={meta.checkMode}
          onClear={onFilterClear}
        />
      );
    default:
      return <></>;
  }
};

ReportLogs.propTypes = {
  format: PropTypes.string.isRequired,
  onFilterClear: PropTypes.func.isRequired,
  logs: PropTypes.array,
  meta: PropTypes.object,
};

ReportLogs.defaultProps = {
  logs: [],
  meta: {},
};

export default ReportLogs;
