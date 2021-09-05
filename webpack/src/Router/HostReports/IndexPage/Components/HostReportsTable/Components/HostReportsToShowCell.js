import React from 'react';
import PropTypes from 'prop-types';
import { Button } from '@patternfly/react-core';

const HostReportsToShowCell = ({ active, id, children }) =>
  active ? (
    <Button
      variant="link"
      isInline
      component="a"
      href={`/hosts/${id}/host_reports`}
    >
      {children}
    </Button>
  ) : (
    <Button variant="link" isInline isDisabled component="a">
      {children}
    </Button>
  );

HostReportsToShowCell.propTypes = {
  active: PropTypes.bool,
  id: PropTypes.number.isRequired,
  children: PropTypes.node,
};

HostReportsToShowCell.defaultProps = {
  active: false,
  children: null,
};

export default HostReportsToShowCell;
