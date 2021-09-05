import React from 'react';
import PropTypes from 'prop-types';
import { Button } from '@patternfly/react-core';

const ReportToShowCell = ({ active, id, children }) =>
  active ? (
    <Button variant="link" isInline component="a" href={`/host_reports/${id}`}>
      {children}
    </Button>
  ) : (
    <Button variant="link" isInline isDisabled component="a">
      {children}
    </Button>
  );

ReportToShowCell.propTypes = {
  active: PropTypes.bool,
  id: PropTypes.number.isRequired,
  children: PropTypes.node,
};

ReportToShowCell.defaultProps = {
  active: false,
  children: null,
};

export default ReportToShowCell;
