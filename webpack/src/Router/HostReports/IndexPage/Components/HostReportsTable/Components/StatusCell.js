import React from 'react';
import PropTypes from 'prop-types';
import { capitalize } from 'lodash';

import './StatusCell.scss';

const StatusCell = ({ statuses }) => (
  <td>
    <ul className="status-list">
      {Object.keys(statuses).map(status => {
        let style = '';
        switch (status) {
          case 'failure':
            style = 'label-danger';
            break;
          default:
            style = 'label-info';
        }
        if (!statuses[status]) style = 'label-default';
        return (
          <li key={status}>
            {`${capitalize(status)}: `}
            <span className={`label ${style}`}>{statuses[status]}</span>
          </li>
        );
      })}
    </ul>
  </td>
);

StatusCell.propTypes = {
  statuses: PropTypes.object.isRequired,
};

export default StatusCell;
