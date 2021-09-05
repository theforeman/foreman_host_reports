import React from 'react';
import PropTypes from 'prop-types';

import { useForemanModal } from 'foremanReact/components/ForemanModal/ForemanModalHooks';

import HostReportsTable from './HostReportsTable';
import { HOST_REPORT_DELETE_MODAL_ID } from '../../constants';

const WrappedHostReportsTable = props => {
  const { setModalOpen: setDeleteModalOpen } = useForemanModal({
    id: HOST_REPORT_DELETE_MODAL_ID,
  });

  const { setToDelete, ...rest } = props;

  const onDeleteClick = rowData => {
    setToDelete(rowData);
    setDeleteModalOpen();
  };

  return <HostReportsTable onDeleteClick={onDeleteClick} {...rest} />;
};

WrappedHostReportsTable.propTypes = {
  setToDelete: PropTypes.func.isRequired,
};

export default WrappedHostReportsTable;
