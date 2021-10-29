import React from 'react';
import PropTypes from 'prop-types';
import JSONTree from 'react-json-tree';
import Immutable from 'seamless-immutable';

import { translate as __ } from 'foremanReact/common/I18n';
import ForemanModal from 'foremanReact/components/ForemanModal';

import { RAW_MSG_MODAL_ID } from '../../../../constants';

const RawMsgModal = ({ body }) => {
  const theme = {
    scheme: 'foreman',
    backgroundColor: 'rgba(0, 0, 0, 255)',
    base00: 'rgba(0, 0, 0, 0)',
  };
  return (
    <ForemanModal
      id={RAW_MSG_MODAL_ID}
      title={__('Raw data')}
      backdrop="static"
      enforceFocus
    >
      <JSONTree
        data={Immutable.asMutable(body, { deep: true })}
        hideRoot
        theme={theme}
      />
    </ForemanModal>
  );
};

RawMsgModal.propTypes = {
  body: PropTypes.object,
};

RawMsgModal.defaultProps = {
  body: {},
};

export default RawMsgModal;
