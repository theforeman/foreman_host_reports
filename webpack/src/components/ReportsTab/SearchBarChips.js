import React from 'react';
import PropTypes from 'prop-types';
import { Chip, ChipGroup } from '@patternfly/react-core';

const SearchBarChips = ({ filters, setFilters }) => (
  <ChipGroup>
    {Object.keys(filters).flatMap(filter =>
      filters[filter] ? (
        <Chip
          key={filter}
          onClick={() =>
            setFilters(prev => ({
              ...prev,
              [filter]: false,
            }))
          }
        >
          {filters[filter]}
        </Chip>
      ) : (
        []
      )
    )}
  </ChipGroup>
);

SearchBarChips.propTypes = {
  filters: PropTypes.array,
  setFilters: PropTypes.func.isRequired,
};

SearchBarChips.defaultProps = {
  filters: [],
};

export default SearchBarChips;
