import React from 'react';
import PropTypes from 'prop-types';
import { capitalize } from 'lodash';

import './StatusCell.scss';

const StatusCell = ({ format, value }) => {
  switch (format) {
    case 'puppet':
      return (
        <td>
          <ul className="status-list">
            {value.map(status => {
              let style = '';
              switch (status[0]) {
                case 'failed':
                  style = 'label-danger';
                  break;
                case 'failed_to_restart':
                  style = 'label-warning';
                  break;
                default:
                  style = 'label-info';
              }
              if (!status[2]) style = 'label-default';
              return (
                <li key={status[0]}>
                  {`${status[1]}: `}
                  <span className={`label ${style}`}>{status[2]}</span>
                </li>
              );
            })}
          </ul>
        </td>
      );
    case 'ansible':
      return (
        <td>
          <ul className="status-list">
            {Object.keys(value).map(status => {
              let style = '';
              switch (status) {
                case 'failed':
                  style = 'label-danger';
                  break;
                case 'skipped':
                  style = 'label-warning';
                  break;
                default:
                  style = 'label-info';
              }
              if (!value[status]) style = 'label-default';
              return (
                <li key={status}>
                  {`${capitalize(status)}: `}
                  <span className={`label ${style}`}>{value[status]}</span>
                </li>
              );
            })}
          </ul>
        </td>
      );
    default:
      return <td>N/A</td>;
  }
};

StatusCell.propTypes = {
  format: PropTypes.string,
  value: PropTypes.any.isRequired,
};

StatusCell.defaultProps = {
  format: 'plain',
};

export default StatusCell;
