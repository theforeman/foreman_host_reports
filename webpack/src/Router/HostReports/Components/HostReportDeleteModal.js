import React from 'react';
import PropTypes from 'prop-types';

import { sprintf, translate as __ } from 'foremanReact/common/I18n';
import ForemanModal from 'foremanReact/components/ForemanModal';
import { foremanUrl } from 'foremanReact/common/helpers';

import { HOST_REPORT_DELETE_MODAL_ID } from '../constants';

const HostReportDeleteModal = ({ toDelete, onSuccess }) => {
  const { id, hostName } = toDelete;

  return (
    <ForemanModal
      id={HOST_REPORT_DELETE_MODAL_ID}
      title={__('Confirm report deletion')}
      backdrop="static"
      enforceFocus
      submitProps={{
        url: foremanUrl(`/api/v2/host_reports/${id}`),
        message: sprintf(
          __('Report for %s was successfully deleted'),
          hostName
        ),
        onSuccess,
        submitBtnProps: {
          bsStyle: 'danger',
          btnText: __('Delete'),
        },
      }}
    >
      {sprintf(
        __('You are about to delete a report for %s. Are you sure?'),
        hostName
      )}
      <ForemanModal.Footer />
    </ForemanModal>
  );
};

HostReportDeleteModal.propTypes = {
  toDelete: PropTypes.object,
  onSuccess: PropTypes.func.isRequired,
};

HostReportDeleteModal.defaultProps = {
  toDelete: {},
};

export default HostReportDeleteModal;
