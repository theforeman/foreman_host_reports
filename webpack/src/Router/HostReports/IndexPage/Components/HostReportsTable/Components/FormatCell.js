import React from 'react';
import PropTypes from 'prop-types';
import { UnknownIcon } from '@patternfly/react-icons';

import { sprintf, translate as __ } from 'foremanReact/common/I18n';

import formats from './formatImages';

import './FormatCell.scss';

const FormatCell = ({ format }) => {
  switch (format) {
    case 'plain':
      return (
        <UnknownIcon
          size="md"
          title={__('Obsolete or custom report formats')}
        />
      );
    case 'puppet':
      return (
        <img
          className="format-img"
          src={formats.puppet}
          alt="Puppet"
          title={sprintf(__('Reported by %s'), 'Puppet')}
        />
      );
    case 'ansible':
      return (
        <img
          className="format-img"
          src={formats.ansible}
          alt="Ansible"
          title={sprintf(__('Reported by %s'), 'Ansible')}
        />
      );
    default:
      return (
        <UnknownIcon size="md" title={sprintf(__('Reported by %s'), format)} />
      );
  }
};

FormatCell.propTypes = {
  format: PropTypes.string,
};

FormatCell.defaultProps = {
  format: 'plain',
};

export default FormatCell;
