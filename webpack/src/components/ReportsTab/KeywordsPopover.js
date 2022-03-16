import React from 'react';
import PropTypes from 'prop-types';
import { Popover, Chip, ChipGroup } from '@patternfly/react-core';
import { TagIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';

const KeywordsPopover = ({ keywords, setFilters }) => {
  const [isVisible, setIsVisible] = React.useState(false);
  const toggleVisibility = () => setIsVisible(v => !v);
  let timeoutID;
  const onMouseLeave = () => {
    timeoutID = setTimeout(() => {
      setIsVisible(false);
    }, 300);
  };

  const onMouseEnter = () => {
    if (timeoutID) {
      clearTimeout(timeoutID);
    }
    setIsVisible(true);
  };
  return (
    <Popover
      aria-label="Popover that shows reports keyords"
      isVisible={isVisible}
      shouldOpen={toggleVisibility}
      shouldClose={toggleVisibility}
      onMouseEnter={onMouseEnter}
      onMouseLeave={onMouseLeave}
      headerContent={<div>{__('Keywords')}</div>}
      bodyContent={
        <ChipGroup>
          {keywords.map(keyword => (
            <Chip
              key={keyword}
              component="button"
              onClick={() =>
                setFilters(prev => ({
                  ...prev,
                  [keyword]: `keyword = ${keyword}`,
                }))
              }
              isOverflowChip
            >
              {keyword}
            </Chip>
          ))}
        </ChipGroup>
      }
    >
      <span onMouseEnter={onMouseEnter} onMouseLeave={onMouseLeave}>
        <TagIcon color={keywords.length ? '#6a6e73' : '#d2d2d2'} />{' '}
        {keywords.length}
      </span>
    </Popover>
  );
};

KeywordsPopover.propTypes = {
  keywords: PropTypes.array,
  setFilters: PropTypes.func.isRequired,
};

KeywordsPopover.defaultProps = {
  keywords: [],
};

export default KeywordsPopover;
