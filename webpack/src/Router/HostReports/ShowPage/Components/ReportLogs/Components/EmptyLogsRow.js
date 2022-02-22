import React from 'react';
import PropTypes from 'prop-types';
import { SearchIcon } from '@patternfly/react-icons';

import DefaultEmptyState from 'foremanReact/components/common/EmptyState';
import { translate as __ } from 'foremanReact/common/I18n';

const EmptyLogsRow = ({ onClear }) => (
  <DefaultEmptyState
    header={__('No results found')}
    icon={<SearchIcon />}
    description={__(
      'No results match this filter criteria. Clear all filters and try again.'
    )}
    action={{
      title: __('Clear all filters'),
      url: '#',
      onClick: onClear,
    }}
  />
);

EmptyLogsRow.propTypes = {
  onClear: PropTypes.func.isRequired,
};

export default EmptyLogsRow;
