import React from 'react';
import PropTypes from 'prop-types';
import { Button, Grid, GridItem } from '@patternfly/react-core';

import PageLayout from 'foremanReact/routes/common/PageLayout/PageLayout';
import { translate as __ } from 'foremanReact/common/I18n';
import { foremanUrl } from 'foremanReact/common/helpers';
import { useForemanModal } from 'foremanReact/components/ForemanModal/ForemanModalHooks';

import HostReportDeleteModal from '../Components/HostReportDeleteModal';
import ReportLogsFilter from './Components/ReportLogsFilter';
import HostReportMetrics from './Components/HostReportMetrics';

import {
  HOSTS_PATH,
  HOST_REPORTS_PATH,
  HOST_REPORT_DELETE_MODAL_ID,
} from '../constants';

const HostReportsShowPage = ({
  id,
  body,
  host,
  reportedAt,
  permissions,
  isLoading,
  fetchAndPush,
}) => {
  const {
    setModalOpen: setDeleteModalOpen,
    setModalClosed: setDeleteModalClosed,
  } = useForemanModal({
    id: HOST_REPORT_DELETE_MODAL_ID,
  });

  const buttons = [];

  if (permissions.canDelete) {
    buttons.push(
      <Button
        key={`host-report-delete-button-${id}`}
        variant="danger"
        isSmall
        onClick={() => setDeleteModalOpen()}
      >
        {__('Delete')}
      </Button>
    );
  }
  buttons.push(
    <Button
      key={`host-report-host-button-${id}`}
      variant="link"
      component="a"
      target="_blank"
      href={foremanUrl(`${HOSTS_PATH}/${host.id}`)}
      isSmall
    >
      {__('Host details')}
    </Button>
  );
  buttons.push(
    <Button
      key={`host-report-other-button-${id}`}
      variant="link"
      component="a"
      target="_blank"
      href={foremanUrl(`${HOSTS_PATH}/${host.id}${HOST_REPORTS_PATH}`)}
      isSmall
    >
      {__('Other reports for this host')}
    </Button>
  );

  const meta = {
    environment: body.environment,
  };

  return (
    <React.Fragment>
      <HostReportDeleteModal
        toDelete={{ id, hostName: host.name }}
        onSuccess={() => {
          setDeleteModalClosed();
          fetchAndPush({ page: 1 });
        }}
      />
      <PageLayout
        header={host.name}
        searchable={false}
        isLoading={isLoading}
        breadcrumbOptions={{
          isSwitchable: false,
          breadcrumbItems: [
            { caption: __('Host Reports'), url: foremanUrl(HOST_REPORTS_PATH) },
            {
              caption: host.name,
              url: foremanUrl(`${HOST_REPORTS_PATH}/${id}`),
            },
          ],
        }}
        toolbarButtons={buttons}
      >
        <Grid hasGutter>
          <GridItem>
            <ReportLogsFilter
              format={body.format}
              logs={body.logs}
              reportedAt={reportedAt}
              meta={meta}
            />
          </GridItem>
          <GridItem>
            <HostReportMetrics metrics={body.metrics} />
          </GridItem>
        </Grid>
      </PageLayout>
    </React.Fragment>
  );
};

HostReportsShowPage.propTypes = {
  id: PropTypes.number.isRequired,
  body: PropTypes.object.isRequired,
  host: PropTypes.object.isRequired,
  reportedAt: PropTypes.string.isRequired,
  permissions: PropTypes.object.isRequired,
  fetchAndPush: PropTypes.func.isRequired,
  isLoading: PropTypes.bool,
};

HostReportsShowPage.defaultProps = {
  isLoading: true,
};

export default HostReportsShowPage;
