import React from 'react';
import PropTypes from 'prop-types';

import { Table } from 'foremanReact/components/common/table';
import Pagination from 'foremanReact/components/Pagination';
import DefaultEmptyState from 'foremanReact/components/common/EmptyState';
import { translate as __ } from 'foremanReact/common/I18n';

import HostReportDeleteModal from '../../../Components/HostReportDeleteModal';

import createHostReportsTableSchema from './HostReportsTableSchema';

const HostReportsTable = ({
  fetchAndPush,
  itemCount,
  results,
  sort,
  pagination,
  toDelete,
  onDeleteClick,
  hostId,
}) => {
  const onDeleteSuccess = () => {
    const currentPage = pagination.page;
    const maxPage = Math.ceil((itemCount - 1) / pagination.perPage);
    fetchAndPush({ page: maxPage < currentPage ? maxPage : currentPage });
  };

  const body =
    itemCount > 0 ? (
      <Table
        key="host-reports-table"
        columns={createHostReportsTableSchema(
          fetchAndPush,
          sort.by,
          sort.order,
          onDeleteClick,
          hostId
        )}
        rows={results}
        id="host-reports-table"
      />
    ) : (
      <DefaultEmptyState
        icon="add-circle-o"
        header={__('No Results')}
        description=""
        documentation={null}
      />
    );

  return (
    <React.Fragment>
      <HostReportDeleteModal toDelete={toDelete} onSuccess={onDeleteSuccess} />
      {body}
      <Pagination itemCount={itemCount} onChange={fetchAndPush} />
    </React.Fragment>
  );
};

HostReportsTable.propTypes = {
  results: PropTypes.array.isRequired,
  fetchAndPush: PropTypes.func.isRequired,
  onDeleteClick: PropTypes.func.isRequired,
  itemCount: PropTypes.number.isRequired,
  sort: PropTypes.object,
  pagination: PropTypes.object.isRequired,
  toDelete: PropTypes.object.isRequired,
  hostId: PropTypes.string,
};

HostReportsTable.defaultProps = {
  sort: { by: '', order: '' },
  hostId: null,
};

export default HostReportsTable;
