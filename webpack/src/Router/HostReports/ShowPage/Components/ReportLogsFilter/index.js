import React, { useState, useEffect, useCallback } from 'react';
import PropTypes from 'prop-types';

import { sprintf, translate as __ } from 'foremanReact/common/I18n';

import { ContextSelector, ContextSelectorItem } from '@patternfly/react-core';

import ReportLogs from '../ReportLogs';

const ReportLogsFilter = ({ format, logs, reportedAt, meta }) => {
  const filterItems = [
    { text: __('All messages'), accepts: [] },
    {
      text: __('Notices, warnings and errors'),
      accepts: ['notice', 'warning', 'err'],
    },
    { text: __('Warnings and errors'), accepts: ['warning', 'err'] },
    { text: __('Errors only'), accepts: ['err'] },
  ];
  const [currentItem, setCurrentItem] = useState(filterItems[0]);
  const [currentFilterItems, setCurrentFilterItems] = useState(filterItems);
  const [searchValue, setSearchValue] = useState('');
  const [isOpen, setIsOpen] = useState(false);
  const [filteredLogs, setFilteredLogs] = useState(logs);

  /* eslint-disable react-hooks/exhaustive-deps */
  const onSearchButtonClick = useCallback(() => {
    const filtered =
      searchValue === ''
        ? filterItems
        : filterItems.filter(item =>
            item.text.toLowerCase().includes(searchValue.toLowerCase())
          );
    setCurrentFilterItems(filtered || []);
  }, [searchValue]);
  /* eslint-enable react-hooks/exhaustive-deps */

  useEffect(() => {
    onSearchButtonClick();
  }, [searchValue, onSearchButtonClick]);

  const onToggle = (event, newIsOpen) => {
    setIsOpen(newIsOpen);
  };
  const onSelect = () => {
    setIsOpen(!isOpen);
  };
  const onSearchInputChange = (value, event) => {
    setSearchValue(event.target.value);
  };
  const filterLogs = (toFilter, accepts) => {
    if (!accepts.length) return toFilter;

    return toFilter.filter(log => accepts.includes(log[0]));
  };

  useEffect(() => {
    setFilteredLogs(filterLogs(logs, currentItem.accepts));
  }, [logs, currentItem]);

  return (
    <>
      <span>{__('Show log messages:')}</span>
      <br />
      <ContextSelector
        id="report-logs-filter"
        toggleText={currentItem.text}
        onSearchInputChange={onSearchInputChange}
        isOpen={isOpen}
        searchInputValue={searchValue}
        onToggle={onToggle}
        onSelect={onSelect}
        onSearchButtonClick={onSearchButtonClick}
        screenReaderLabel="Selected Messages:"
      >
        {currentFilterItems.map((item, i) => (
          <ContextSelectorItem
            key={i + 1}
            id={`select_messages_${i}`}
            onClick={() => {
              setCurrentItem(item);
            }}
            isDisabled={item.text === currentItem.text}
          >
            {item.text}
          </ContextSelectorItem>
        ))}
      </ContextSelector>
      <p className="ra">{sprintf(__('Reported at %s'), reportedAt)}</p>
      <ReportLogs format={format} logs={filteredLogs} meta={meta} />
    </>
  );
};

ReportLogsFilter.propTypes = {
  format: PropTypes.string.isRequired,
  reportedAt: PropTypes.string.isRequired,
  meta: PropTypes.object,
  logs: PropTypes.array,
};

ReportLogsFilter.defaultProps = {
  logs: [],
  meta: {},
};

export default ReportLogsFilter;
