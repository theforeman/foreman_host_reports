import React, { useState } from 'react';
import PropTypes from 'prop-types';

import { Alert, AlertActionCloseButton } from '@patternfly/react-core';

import { translate as __ } from 'foremanReact/common/I18n';

import { msgLevelClasses } from './helpers';

const AnsibleLogs = ({ logs, checkMode }) => {
  const [alertVisibility, setAlertVisibility] = useState(true);
  return (
    <>
      {checkMode && alertVisibility ? (
        <Alert
          variant="info"
          isInline
          title={__('Ansible check mode')}
          actionClose={
            <AlertActionCloseButton onClose={() => setAlertVisibility(false)} />
          }
        >
          {__('Notice that ansible roles run in check mode.')}
        </Alert>
      ) : null}
      <table
        id="report_log"
        className="table table-bordered table-striped table-hover"
      >
        <thead>
          <tr>
            <th className="col col-md"> {__('Level')} </th>
            <th className="col col-md-3"> {__('Task')} </th>
            <th className="col col-md-9"> {__('Message')} </th>
          </tr>
        </thead>
        <tbody>
          {logs.map((log, idx) => (
            <tr key={`tr-${idx + 1}`}>
              <td>
                <span className={msgLevelClasses(log.level)}>{log.level}</span>
              </td>
              <td className="break-me">{log.task.name}</td>
              {Array.isArray(log.friendlyMessage) ? (
                <td>
                  <ul>
                    {log.friendlyMessage.map((msg, i) => (
                      <li key={`li-${i + 1}`}>{msg}</li>
                    ))}
                  </ul>
                </td>
              ) : (
                <td className="break-me">{log.friendlyMessage}</td>
              )}
            </tr>
          ))}
          {logs.length === 0 ? (
            <tr key="tr-0">
              <td colSpan="3">{__('Nothing to show')}</td>
            </tr>
          ) : null}
        </tbody>
      </table>
    </>
  );
};

AnsibleLogs.propTypes = {
  logs: PropTypes.array.isRequired,
  checkMode: PropTypes.bool,
};

AnsibleLogs.defaultProps = {
  checkMode: false,
};

export default AnsibleLogs;
