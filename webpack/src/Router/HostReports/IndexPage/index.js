import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { useSelector, useDispatch } from 'react-redux';
import { isEmpty } from 'lodash';

import { get } from 'foremanReact/redux/API';

import Loading from 'foremanReact/components/Loading';
import DefaultEmptyState from 'foremanReact/components/common/EmptyState';
import { WelcomeConfigReports } from 'foremanReact/components/ConfigReports/Welcome';

import { HOST_REPORTS_API_REQUEST_KEY } from './constants';

import HostReportsIndexPage from './IndexPage';

import {
  selectHostReports,
  selectPage,
  selectPerPage,
  selectSearch,
  selectSort,
  selectHasData,
  selectHasError,
  selectIsLoading,
  selectSubtotal,
  selectErrorMessage,
} from './IndexPageSelectors';

import { reloadWithSearch, fetchAndPush } from './IndexPageActions';

import { hostReportsIndexUrl } from './IndexPageHelpers';

const ConnectedHostReportsIndexPage = ({ history, match }) => {
  const dispatch = useDispatch();

  const reports = useSelector(selectHostReports);
  const page = useSelector(selectPage);
  const perPage = useSelector(selectPerPage);
  const search = useSelector(selectSearch);
  const sort = useSelector(selectSort);
  const isLoading = useSelector(selectIsLoading);
  const hasData = useSelector(selectHasData);
  const hasError = useSelector(selectHasError);
  const itemCount = useSelector(selectSubtotal);
  const error = useSelector(selectErrorMessage);

  const { hostId } = match.params;

  useEffect(() => {
    dispatch(
      get({
        key: HOST_REPORTS_API_REQUEST_KEY,
        url: hostReportsIndexUrl(hostId),
      })
    );
  }, [dispatch, hostId]);

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

  if (!isLoading && !hasError && !hasData && isEmpty(search)) {
    return <WelcomeConfigReports />;
  }

  return (
    <HostReportsIndexPage
      fetchAndPush={params => dispatch(fetchAndPush(params))}
      search={search}
      isLoading={isLoading}
      hasData={hasData}
      reports={reports}
      page={page}
      perPage={perPage}
      sort={sort}
      itemCount={itemCount}
      reloadWithSearch={query => dispatch(reloadWithSearch(query))}
      history={history}
      hostId={hostId}
    />
  );
};

ConnectedHostReportsIndexPage.propTypes = {
  history: PropTypes.object.isRequired,
  match: PropTypes.object.isRequired,
};

export default ConnectedHostReportsIndexPage;
