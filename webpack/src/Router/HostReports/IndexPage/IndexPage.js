import React, { useState } from 'react';
import PropTypes from 'prop-types';

import PageLayout from 'foremanReact/routes/common/PageLayout/PageLayout';
import ExportButton from 'foremanReact/routes/common/PageLayout/components/ExportButton/ExportButton';
import { translate as __ } from 'foremanReact/common/I18n';
import { getURIQuery } from 'foremanReact/common/helpers';

import {
  HOST_REPORTS_SEARCH_PROPS,
  HOST_REPORTS_API_PLAIN_PATH,
} from './constants';

import HostReportsTable from './Components/HostReportsTable';

import { getExportUrl } from './IndexPageHelpers';

const HostReportsIndexPage = ({
  fetchAndPush,
  search,
  isLoading,
  hasData,
  reports,
  page,
  perPage,
  sort,
  itemCount,
  reloadWithSearch,
  history,
  hostId,
}) => {
  const [toDelete, setToDelete] = useState({});

  const url = HOST_REPORTS_API_PLAIN_PATH + history.location.search;
  const uriQuery = getURIQuery(url);
  const exportBtn = (
    <ExportButton url={getExportUrl(url, uriQuery)} title={__('Export')} />
  );

  return (
    <PageLayout
      header={__('Host Reports')}
      searchable={!isLoading}
      searchProps={HOST_REPORTS_SEARCH_PROPS}
      searchQuery={search}
      isLoading={isLoading && hasData}
      onSearch={reloadWithSearch}
      onBookmarkClick={reloadWithSearch}
      toolbarButtons={exportBtn}
    >
      <HostReportsTable
        results={reports}
        fetchAndPush={fetchAndPush}
        pagination={{ page, perPage }}
        itemCount={itemCount}
        sort={sort}
        toDelete={toDelete}
        setToDelete={setToDelete}
        hostId={hostId}
      />
    </PageLayout>
  );
};

HostReportsIndexPage.propTypes = {
  fetchAndPush: PropTypes.func.isRequired,
  search: PropTypes.string,
  isLoading: PropTypes.bool.isRequired,
  hasData: PropTypes.bool.isRequired,
  reports: PropTypes.array.isRequired,
  page: PropTypes.number,
  perPage: PropTypes.number,
  sort: PropTypes.object.isRequired,
  itemCount: PropTypes.number.isRequired,
  reloadWithSearch: PropTypes.func.isRequired,
  history: PropTypes.object.isRequired,
  hostId: PropTypes.string,
};

HostReportsIndexPage.defaultProps = {
  page: null,
  perPage: null,
  search: '',
  hostId: null,
};

export default HostReportsIndexPage;
