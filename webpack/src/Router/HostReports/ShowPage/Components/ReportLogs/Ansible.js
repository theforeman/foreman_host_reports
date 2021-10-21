import React, { useState } from 'react';
import PropTypes from 'prop-types';

import { Alert, AlertActionCloseButton, Button } from '@patternfly/react-core';

import { translate as __ } from 'foremanReact/common/I18n';
import { useForemanModal } from 'foremanReact/components/ForemanModal/ForemanModalHooks';

import RawMsgModal from './Components/RawMsgModal';

import { msgLevelClasses } from './helpers';

import { RAW_MSG_MODAL_ID } from '../../../constants';

const AnsibleLogs = ({ logs, checkMode }) => {
  const [alertVisibility, setAlertVisibility] = useState(true);
  const [selectedMsg, setSelectedMsg] = useState(0);
  const { setModalOpen: setRawModalOpen } = useForemanModal({
    id: RAW_MSG_MODAL_ID,
  });

  const rawMsg = idx => {
    const onClick = () => {
      setSelectedMsg(idx);
      setRawModalOpen();
    };
    return <Button onClick={onClick} variant="secondary">{__('Show')}</Button>;
  };

  return (
    <>
      <RawMsgModal body={logs[selectedMsg]} />
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
            <th className="col col-md-8"> {__('Message')} </th>
            <th className="col col-md-1"> {__('Raw data')} </th>
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
            <td className="break-me">{rawMsg(idx)}</td>
            </tr>
          ))}
          {logs.length === 0 ? (
            <tr key="tr-0">
              <td colSpan="4">{__('Nothing to show')}</td>
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
