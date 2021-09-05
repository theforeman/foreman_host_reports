import { camelCase, isEmpty } from 'lodash';
import Immutable from 'seamless-immutable';
import { STATUS } from 'foremanReact/constants';
import { deepPropsToCamelCase } from 'foremanReact/common/helpers';
import {
  selectAPIStatus,
  selectAPIResponse,
  selectAPIErrorMessage,
} from 'foremanReact/redux/API/APISelectors';

import { HOST_REPORTS_API_REQUEST_KEY } from './constants';

export const emptyResponse = {
  results: [],
  page: 0,
  perPage: 0,
  search: '',
  sort: {},
  canCreate: false,
  subtotal: 0,
};

const selectHostReportsPageResponse = state => {
  const response = deepPropsToCamelCase(
    selectAPIResponse(state, HOST_REPORTS_API_REQUEST_KEY)
  );
  if (isEmpty(response)) {
    return Immutable(emptyResponse);
  }
  return response;
};

export const selectIsLoading = state => {
  const status = selectHostReportsPageStatus(state);
  return !status || status === STATUS.PENDING;
};

const selectHostReportsPageStatus = state =>
  selectAPIStatus(state, HOST_REPORTS_API_REQUEST_KEY);

export const selectHasError = state =>
  selectHostReportsPageStatus(state) === STATUS.ERROR;

export const selectHostReports = state => {
  if (selectHasError(state)) {
    return [];
  }
  return selectHostReportsPageResponse(state).results;
};

export const selectHasData = state => {
  const status = selectHostReportsPageStatus(state);
  const results = selectHostReports(state);

  return status === STATUS.RESOLVED && results && results.length > 0;
};

export const selectPage = state =>
  selectHostReportsPageResponse(state).page || 1;
export const selectPerPage = state =>
  selectHostReportsPageResponse(state).perPage || 20;
export const selectSearch = state =>
  selectHostReportsPageResponse(state).search;

export const selectSort = state => {
  const sort = selectHostReportsPageResponse(state).sort || Immutable({});
  if (sort.by && sort.order) {
    return { ...sort, by: camelCase(sort.by) };
  }
  return sort;
};

export const selectSubtotal = state =>
  selectHostReportsPageResponse(state).subtotal || 0;

export const selectErrorMessage = state => {
  if (!selectHasError(state)) return { message: '', details: '' };
  const error = selectHostReportsPageResponse(state).response?.data?.error;

  if (error) return error;

  return {
    message: selectAPIErrorMessage(state, HOST_REPORTS_API_REQUEST_KEY),
    details: '',
  };
};
