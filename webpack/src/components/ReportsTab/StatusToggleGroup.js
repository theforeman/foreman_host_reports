import React from 'react';
import PropTypes from 'prop-types';
import { ToggleGroup, ToggleGroupItem } from '@patternfly/react-core';
import {
  ExclamationCircleIcon,
  SyncAltIcon,
  CheckCircleIcon,
} from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';

const StatusToggleGroup = ({ setSelected, selected }) => {
  const onChange = (isSelected, { currentTarget: { id: statusName } }) =>
    setSelected(prev => ({
      ...prev,
      [statusName]: isSelected ? `${statusName} > 0` : false,
    }));

  return (
    <ToggleGroup aria-label="Icon variant toggle group">
      <ToggleGroupItem
        icon={
          <ExclamationCircleIcon color="var(--pf-global--palette--red-100)" />
        }
        text={__('Failed')}
        aria-label="filter failed icon button"
        buttonId="failed"
        isSelected={selected.failed}
        onChange={onChange}
      />
      <ToggleGroupItem
        icon={<SyncAltIcon color="var(--pf-global--palette--orange-300)" />}
        text={__('Changed')}
        aria-label="filter changed icon button"
        buttonId="changed"
        isSelected={selected.changed}
        onChange={onChange}
      />
      <ToggleGroupItem
        icon={<CheckCircleIcon color="var(--pf-global--success-color--100)" />}
        text={__('Unchanged')}
        aria-label="filter unchanged icon button"
        buttonId="unchanged"
        isSelected={selected.unchanged}
        onChange={onChange}
      />
    </ToggleGroup>
  );
};

StatusToggleGroup.propTypes = {
  setSelected: PropTypes.func.isRequired,
  selected: PropTypes.object,
};

StatusToggleGroup.defaultProps = {
  selected: { failed: false, changed: false, unchanged: false },
};

export default StatusToggleGroup;
