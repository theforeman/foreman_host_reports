import React from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';

import { sprintf, translate as __ } from 'foremanReact/common/I18n';
import * as diffModalActions from 'foremanReact/components/ConfigReports/DiffModal/DiffModalActions';
import DiffModal from 'foremanReact/components/ConfigReports/DiffModal';

import { reportTag } from './helpers';

const PuppetLogs = ({ logs, environment }) => {
  const dispatch = useDispatch();
  const showDiff = (e, diff, title) => {
    e.preventDefault();
    dispatch(diffModalActions.createDiff(diff, title));
  };

  return (
    <>
      <DiffModal />
      {environment ? (
        <p className="ra">
          {sprintf(__('Puppet Environment: %s'), environment)}
        </p>
      ) : null}
      <table
        id="report_log"
        className="table table-bordered table-striped table-hover"
      >
        <thead>
          <tr>
            <th> {__('Level')} </th>
            <th> {__('Resource')} </th>
            <th> {__('Message')} </th>
          </tr>
        </thead>
        <tbody>
          {logs.map((log, i) => (
            <tr key={`tr-${i + 1}`}>
              <td>
                <span className={reportTag(log[0])}>{log[0]}</span>
              </td>
              <td className="break-me">{log[1]}</td>
              {log[2].startsWith('\n---') ? (
                <td className="break-me">
                  <a
                    onClick={e =>
                      showDiff(e, log[2], /File\[(.*?)\]/.exec(log[1])[1])
                    }
                  >
                    {__('Show Diff')}
                  </a>
                </td>
              ) : (
                <td className="break-me">{log[2]}</td>
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

PuppetLogs.propTypes = {
  logs: PropTypes.array.isRequired,
  environment: PropTypes.string,
};

PuppetLogs.defaultProps = {
  environment: null,
};

export default PuppetLogs;
