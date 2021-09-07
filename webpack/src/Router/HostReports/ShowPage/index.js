import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { useSelector, useDispatch } from 'react-redux';

import { get } from 'foremanReact/redux/API';
import { foremanUrl } from 'foremanReact/common/helpers';

import Loading from 'foremanReact/components/Loading';
import DefaultEmptyState from 'foremanReact/components/common/EmptyState';

import HostReportsShowPage from './ShowPage';

import { HOST_REPORT_REQUEST_KEY, HOST_REPORTS_PATH } from '../constants';
import {
  selectHostReport,
  selectIsLoading,
  selectHasError,
  selectErrorMessage,
  selectPermissions,
} from './ShowPageSelectors';

import { fetchAndPush } from '../IndexPage/IndexPageActions';

const ConnectedHostReportsShowPage = ({ match }) => {
  const dispatch = useDispatch();

  const report = useSelector(selectHostReport);
  const isLoading = useSelector(selectIsLoading);
  const hasError = useSelector(selectHasError);
  const error = useSelector(selectErrorMessage);
  const permissions = useSelector(selectPermissions);

  const { id } = match.params;

  useEffect(() => {
    dispatch(
      get({
        key: HOST_REPORT_REQUEST_KEY,
        url: foremanUrl(`${HOST_REPORTS_PATH}/${id}`),
      })
    );
  }, [dispatch, id]);

  if (isLoading && !hasError) return <Loading />;

  if (!isLoading && hasError) {
    return (
      <DefaultEmptyState
        icon="error-circle-o"
        header={error.message}
        description={error.details || ''}
        documentation={null}
      />
    );
  }

  return (
    <HostReportsShowPage
      id={report.id}
      body={report.body}
      format={report.format}
      host={report.host}
      reportedAt={report.reportedAt}
      permissions={permissions}
      isLoading={isLoading}
      fetchAndPush={params => dispatch(fetchAndPush(params))}
    />
  );
};

ConnectedHostReportsShowPage.propTypes = {
  match: PropTypes.object.isRequired,
};

export default ConnectedHostReportsShowPage;
