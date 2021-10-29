import React from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';

import {
  TableComposable,
  Thead,
  Tbody,
  Tr,
  Th,
  Td,
} from '@patternfly/react-table';

import { translate as __ } from 'foremanReact/common/I18n';
import * as diffModalActions from 'foremanReact/components/ConfigReports/DiffModal/DiffModalActions';
import DiffModal from 'foremanReact/components/ConfigReports/DiffModal';

import EmptyLogsRow from './Components/EmptyLogsRow';

import { msgLevelClasses } from './helpers';

const PuppetLogs = ({ logs, onClear }) => {
  const dispatch = useDispatch();
  const showDiff = (e, diff, title) => {
    e.preventDefault();
    dispatch(diffModalActions.createDiff(diff, title));
  };

  return (
    <>
      <DiffModal />
      <TableComposable id="report_log" variant="compact">
        <Thead noWrap>
          <Tr>
            <Th className="col col-md"> {__('Level')} </Th>
            <Th className="col col-md-3"> {__('Resource')} </Th>
            <Th className="col col-md-9"> {__('Message')} </Th>
          </Tr>
        </Thead>
        <Tbody>
          {logs.map((log, i) => (
            <Tr key={`tr-${i + 1}`}>
              <Td>
                <span className={msgLevelClasses(log[0])}>{log[0]}</span>
              </Td>
              <Td className="break-me">{log[1]}</Td>
              {log[2].startsWith('\n---') ? (
                <Td className="break-me">
                  <a
                    onClick={e =>
                      showDiff(e, log[2], /File\[(.*?)\]/.exec(log[1])[1])
                    }
                  >
                    {__('Show Diff')}
                  </a>
                </Td>
              ) : (
                <Td className="break-me">{log[2]}</Td>
              )}
            </Tr>
          ))}
          {logs.length === 0 ? (
            <Tr key="tr-0">
              <Td colSpan={3}>
                <EmptyLogsRow onClear={onClear} />
              </Td>
            </Tr>
          ) : null}
        </Tbody>
      </TableComposable>
    </>
  );
};

PuppetLogs.propTypes = {
  logs: PropTypes.array.isRequired,
  onClear: PropTypes.func.isRequired,
};

export default PuppetLogs;
