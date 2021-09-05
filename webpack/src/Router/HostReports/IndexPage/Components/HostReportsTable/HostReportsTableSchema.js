import { translate as __ } from 'foremanReact/common/I18n';
import {
  column,
  sortableColumn,
  headerFormatterWithProps,
  deleteActionCellFormatter,
  cellFormatter,
} from 'foremanReact/components/common/table';

import {
  formatCellFormatter,
  reportToShowFormatter,
  hostReportsToShowFormatter,
  statusFormatter,
} from './Components/Formatters';

const sortControllerFactory = (apiCall, sortBy, sortOrder) => ({
  apply: (by, order) => {
    apiCall({ sort: { by, order } });
  },
  property: sortBy,
  order: sortOrder,
});

const createHostReportsTableSchema = (
  apiCall,
  by,
  order,
  onDeleteClick,
  hostId
) => {
  const sortController = sortControllerFactory(apiCall, by, order);
  const hostColumn = hostId
    ? []
    : [
        sortableColumn('hostName', __('Host'), 3, sortController, [
          hostReportsToShowFormatter(),
        ]),
      ];

  return hostColumn.concat([
    sortableColumn('reportedAt', __('Last report'), 1, sortController, [
      reportToShowFormatter(),
    ]),
    sortableColumn('format', __('Format'), 1, sortController, [
      formatCellFormatter(),
    ]),
    column(
      'status',
      __('Overall status'),
      [headerFormatterWithProps],
      [statusFormatter()],
      { className: `col-lg-auto` }
    ),
    column(
      'actions',
      __('Actions'),
      [headerFormatterWithProps],
      [deleteActionCellFormatter(onDeleteClick), cellFormatter],
      { className: `col-md-1` }
    ),
  ]);
};

export default createHostReportsTableSchema;
