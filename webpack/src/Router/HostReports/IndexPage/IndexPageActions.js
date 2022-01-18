import history from 'foremanReact/history';
import { get } from 'foremanReact/redux/API';
import { stringifyParams, getParams } from 'foremanReact/common/urlHelpers';

import { buildQuery } from './IndexPageHelpers';
import {
  HOST_REPORTS_API_PATH,
  HOST_REPORTS_PATH,
  HOST_REPORTS_API_REQUEST_KEY,
} from './constants';

export const initializeHostReports = () => dispatch => {
  const params = getParams();
  dispatch(fetchHostReports({ per_page: params.perPage, ...params }));
  if (!history.action === 'POP') {
    history.replace({
      pathname: HOST_REPORTS_PATH,
      search: stringifyParams(params),
    });
  }
};

export const fetchHostReports = (
  /* eslint-disable-next-line camelcase */
  { page, per_page, searchQuery, sort },
  url = HOST_REPORTS_API_PATH
) => async dispatch => {
  const sortString =
    sort && Object.keys(sort).length > 0 ? `${sort.by} ${sort.order}` : '';

  return dispatch(
    get({
      key: HOST_REPORTS_API_REQUEST_KEY,
      url,
      params: {
        page,
        per_page,
        search: searchQuery,
        order: sortString,
      },
    })
  );
};

export const fetchAndPush = (params = {}) => (dispatch, getState) => {
  const query = buildQuery(params, getState());
  dispatch(fetchHostReports(query));
  history.push({
    pathname: HOST_REPORTS_PATH,
    search: stringifyParams({ perPage: query.per_page, ...query }),
  });
};

export const reloadWithSearch = query => dispatch => {
  dispatch(fetchAndPush({ searchQuery: query, page: 1 }));
};
