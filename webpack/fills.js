import React from 'react';
import { addGlobalFill } from 'foremanReact/components/common/Fill/GlobalFill';
import ReportsTab from './src/components/ReportsTab';

const fills = [
  {
    slot: 'host-details-page-tabs',
    name: 'Reports',
    component: props => <ReportsTab {...props} />,
    weight: 450,
  },
];

export const registerFills = () => {
  fills.forEach(({ slot, name, component: Component, weight }, index) =>
    addGlobalFill(
      slot,
      name,
      <Component key={`host-reports-fill-${index}`} />,
      weight
    )
  );
};
