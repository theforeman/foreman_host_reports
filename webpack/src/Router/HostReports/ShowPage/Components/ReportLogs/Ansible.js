import React, { useState } from 'react';
import PropTypes from 'prop-types';

import { Alert, AlertActionCloseButton, Button } from '@patternfly/react-core';

import {
  TableComposable,
  Thead,
  Tbody,
  Tr,
  Th,
  Td,
} from '@patternfly/react-table';

import { translate as __ } from 'foremanReact/common/I18n';
import { useForemanModal } from 'foremanReact/components/ForemanModal/ForemanModalHooks';

import RawMsgModal from './Components/RawMsgModal';
import EmptyLogsRow from './Components/EmptyLogsRow';

import { msgLevelClasses } from './helpers';

import { RAW_MSG_MODAL_ID } from '../../../constants';

const AnsibleLogs = ({ logs, checkMode, onClear }) => {
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
    return (
      <Button isSmall onClick={onClick} variant="secondary">
        {__('Show')}
      </Button>
    );
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
      <TableComposable id="report_log" variant="compact">
        <Thead noWrap>
          <Tr>
            <Th> {__('Level')} </Th>
            <Th> {__('Task')} </Th>
            <Th> {__('Message')} </Th>
            <Th> {__('Raw data')} </Th>
          </Tr>
        </Thead>
        <Tbody>
          {logs.map((log, idx) => (
            <Tr key={`tr-${idx + 1}`}>
              <Td>
                <span className={msgLevelClasses(log.level)}>{log.level}</span>
              </Td>
              <Td>{log.task.name}</Td>
              {Array.isArray(log.friendlyMessage) ? (
                <Td>
                  <ul>
                    {log.friendlyMessage.map((msg, i) => (
                      <li key={`li-${i + 1}`}>{msg}</li>
                    ))}
                  </ul>
                </Td>
              ) : (
                <Td>{log.friendlyMessage}</Td>
              )}
              <Td>{rawMsg(idx)}</Td>
            </Tr>
          ))}
          {logs.length === 0 ? (
            <Tr key="tr-0">
              <Td colSpan={4}>
                <EmptyLogsRow onClear={onClear} />
              </Td>
            </Tr>
          ) : null}
        </Tbody>
      </TableComposable>
    </>
  );
};

AnsibleLogs.propTypes = {
  logs: PropTypes.array.isRequired,
  onClear: PropTypes.func.isRequired,
  checkMode: PropTypes.bool,
};

AnsibleLogs.defaultProps = {
  checkMode: false,
};

export default AnsibleLogs;
