import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';

import { translate as __ } from 'foremanReact/common/I18n';

import {
  Select,
  SelectOption,
  SelectVariant,
  Toolbar,
  ToolbarContent,
  ToolbarToggleGroup,
  ToolbarGroup,
  ToolbarItem,
} from '@patternfly/react-core';
import { FilterIcon } from '@patternfly/react-icons';

import ReportLogs from '../ReportLogs';

const ReportLogsFilter = ({ format, meta }) => {
  const { logs } = meta;
  const filterItems = [
    { text: __('All messages'), accepts: [] },
    {
      text: __('Notices, warnings and errors'),
      accepts: ['notice', 'warning', 'err'],
    },
    { text: __('Warnings and errors'), accepts: ['warning', 'err'] },
    { text: __('Errors only'), accepts: ['err'] },
  ];
  const [filteredLogs, setFilteredLogs] = useState(logs);
  const [isOpen, setIsOpen] = useState(false);
  const [selected, setSelected] = useState(filterItems[0]);

  const onToggle = isExpanded => {
    setIsOpen(isExpanded);
  };
  const onSelect = (event, selection) => {
    const item = filterItems.find(i => i.text === selection);
    setSelected(item);
    setIsOpen(false);
  };
  const filterLogs = (toFilter, accepts) => {
    if (!accepts.length) return toFilter;

    return toFilter.filter(log => accepts.includes(log[0] || log.level));
  };

  useEffect(() => {
    setFilteredLogs(filterLogs(logs, selected.accepts));
  }, [logs, selected]);

  const onFilterClear = () => {
    setSelected(filterItems[0]);
  };

  return (
    <>
      <Toolbar id="logs-toolbar">
        <ToolbarContent>
          <ToolbarToggleGroup toggleIcon={<FilterIcon />} breakpoint="lg">
            <ToolbarGroup variant="filter-group">
              <ToolbarItem variant="label">{__('Message')}</ToolbarItem>
              <ToolbarItem>
                <Select
                  variant={SelectVariant.single}
                  onToggle={onToggle}
                  onSelect={onSelect}
                  selections={selected.text}
                  isOpen={isOpen}
                >
                  {filterItems.map((option, index) => (
                    <SelectOption key={index} value={option.text} />
                  ))}
                </Select>
              </ToolbarItem>
            </ToolbarGroup>
          </ToolbarToggleGroup>
        </ToolbarContent>
      </Toolbar>
      <ReportLogs
        format={format}
        logs={filteredLogs}
        meta={meta}
        onFilterClear={onFilterClear}
      />
    </>
  );
};

ReportLogsFilter.propTypes = {
  format: PropTypes.string.isRequired,
  meta: PropTypes.object,
};

ReportLogsFilter.defaultProps = {
  meta: {},
};

export default ReportLogsFilter;
