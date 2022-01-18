import URI from 'urijs';
import { snakeCase } from 'lodash';
import { compose } from 'redux';

import { foremanUrl } from 'foremanReact/common/helpers';

import {
  selectSort,
  selectPage,
  selectPerPage,
  selectSearch,
} from './IndexPageSelectors';

import { HOST_REPORTS_API_PATH } from './constants';

export const buildQuery = (query, state) => {
  const querySort = pickSort(query, state);

  return {
    page: query.page || selectPage(state),
    per_page: query.per_page || selectPerPage(state),
    searchQuery:
      query.searchQuery === undefined ? selectSearch(state) : query.searchQuery,
    ...(querySort && { sort: querySort }),
  };
};

export const pickSort = (query, state) =>
  checkSort(query.sort)
    ? transformSort(query.sort)
    : checkSort(compose(transformSort, selectSort)(state));

const checkSort = sort => (sort && sort.by && sort.order ? sort : undefined);

const transformSort = sort => ({ ...sort, by: snakeCase(sort.by) });

export const getExportUrl = (path, query) => {
  let url = new URI(path);
  url = url.pathname(`${url.pathname()}/export`);
  url.addSearch(query);
  return url.toString();
};

export const hostReportsIndexUrl = hostId => {
  if (!hostId) return foremanUrl(HOST_REPORTS_API_PATH);

  return foremanUrl(
    `/api/v2/hosts/${hostId}/host_reports?include_permissions=true`
  );
};
