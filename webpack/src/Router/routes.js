import React from 'react';
import ConnectedHostReportsIndexPage from './HostReports/IndexPage';
import ConnectedHostReportsShowPage from './HostReports/ShowPage';

const ForemanHostReportsRoutes = [
  {
    path: '/host_reports',
    exact: true,
    render: props => <ConnectedHostReportsIndexPage {...props} />,
  },
  {
    path: '/host_reports/:id([0-9]+)',
    exact: true,
    render: props => <ConnectedHostReportsShowPage {...props} />,
  },
  {
    path: '/hosts/:hostId([0-9]+)/host_reports',
    exact: true,
    render: props => <ConnectedHostReportsIndexPage {...props} />,
  },
];

export default ForemanHostReportsRoutes;
