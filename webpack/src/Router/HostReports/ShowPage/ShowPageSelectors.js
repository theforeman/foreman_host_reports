import { STATUS } from 'foremanReact/constants';
import { deepPropsToCamelCase } from 'foremanReact/common/helpers';
import {
  selectAPIStatus,
  selectAPIResponse,
  selectAPIErrorMessage,
} from 'foremanReact/redux/API/APISelectors';

import { HOST_REPORT_REQUEST_KEY } from '../constants';

const selectHostReportResponse = state => {
  const response = deepPropsToCamelCase(
    selectAPIResponse(state, HOST_REPORT_REQUEST_KEY)
  );
  return response;
};

export const selectIsLoading = state => {
  const status = selectHostReportPageStatus(state);
  return !status || status === STATUS.PENDING;
};

const selectHostReportPageStatus = state =>
  selectAPIStatus(state, HOST_REPORT_REQUEST_KEY);

export const selectHasError = state =>
  selectHostReportPageStatus(state) === STATUS.ERROR;

export const selectHostReport = state => {
  if (selectHasError(state)) {
    return [];
  }
  return selectHostReportResponse(state).hostReport;
};

export const selectSearch = state => selectHostReportResponse(state).search;

export const selectPermissions = state =>
  selectHostReportResponse(state).permissions || {};

export const selectErrorMessage = state => {
  if (!selectHasError(state)) return { message: '', details: '' };
  const error = selectHostReportResponse(state).response?.data?.error;

  if (error) return error;

  return {
    message: selectAPIErrorMessage(state, HOST_REPORT_REQUEST_KEY),
    details: '',
  };
};
