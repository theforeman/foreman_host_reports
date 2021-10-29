import React from 'react';
import JSONTree from 'react-json-tree';
import PropTypes from 'prop-types';
import {
  Button,
  Grid,
  GridItem,
  Toolbar,
  ToolbarItem,
  ToolbarContent,
} from '@patternfly/react-core';

import PageLayout from 'foremanReact/routes/common/PageLayout/PageLayout';
import { sprintf, translate as __ } from 'foremanReact/common/I18n';
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
  format,
  host,
  reportedAt,
  permissions,
  isLoading,
  fetchAndPush,
}) => {
  const reportedAtLocal = new Date(reportedAt);
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

  const meta = {};
  switch (format) {
    case 'puppet':
      meta.logs = body.logs;
      break;
    case 'ansible':
      meta.checkMode = body.checkMode;
      meta.logs = body.results;
      break;
    default:
      break;
  }

  const theme = {
    scheme: 'foreman',
    backgroundColor: 'rgba(0, 0, 0, 255)',
    base00: 'rgba(0, 0, 0, 0)',
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
        {format === 'plain' ? (
          <JSONTree data={body} hideRoot theme={theme} />
        ) : (
          <Grid hasGutter>
            <GridItem>
              <Toolbar id="meta-toolbar">
                <ToolbarContent>
                  <ToolbarItem>
                    {sprintf(
                      __('Reported at %s'),
                      reportedAtLocal.toLocaleString()
                    )}
                  </ToolbarItem>
                  {format === 'puppet' ? (
                    <>
                      <ToolbarItem variant="separator" />
                      <ToolbarItem>
                        {sprintf(
                          __('Puppet Environment: %s'),
                          body.environment
                        )}
                      </ToolbarItem>
                    </>
                  ) : null}
                </ToolbarContent>
              </Toolbar>
            </GridItem>
            <GridItem>
              <ReportLogsFilter format={format} meta={meta} />
            </GridItem>
            {format === 'puppet' ? (
              <GridItem>
                <HostReportMetrics metrics={body.metrics} />
              </GridItem>
            ) : null}
          </Grid>
        )}
      </PageLayout>
    </React.Fragment>
  );
};

HostReportsShowPage.propTypes = {
  id: PropTypes.number.isRequired,
  body: PropTypes.object.isRequired,
  format: PropTypes.string.isRequired,
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
