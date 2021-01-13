import React from 'react';
import WelcomePage from './WelcomePage';

const routes = [
  {
    path: '/foreman_host_reports/welcome',
    exact: true,
    render: (props) => <WelcomePage {...props} />,
  },
];

export default routes;
