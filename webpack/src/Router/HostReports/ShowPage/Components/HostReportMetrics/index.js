import React from 'react';
import PropTypes from 'prop-types';

import { Grid, GridItem } from '@patternfly/react-core';

import { cloneDeep, remove } from 'lodash';

import ChartBox from 'foremanReact/components/ChartBox/ChartBox';

import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';

import './HostReportMetrics.scss';

const HostReportMetrics = ({
  metrics: {
    time: { values: timeValues },
    resources: { values: resValues },
  },
}) => {
  const clonedTimeValues = cloneDeep(timeValues).filter(v => v[2] >= 0.001);
  const totalTime = remove(clonedTimeValues, val => val[0] === 'total');
  const metricsChartData = clonedTimeValues
    .map(v => [v[1], parseFloat(v[2].toFixed(4))])
    .sort((a, b) => b[1] - a[1]);

  const clonedStatuses = cloneDeep(resValues);
  const totalStatuses = remove(clonedStatuses, val => val[0] === 'total');
  const statuses = clonedStatuses
    .map(v => [v[1], v[2]])
    .sort((a, b) => b[1] - a[1]);

  const createRow = ([name, value], i) => (
    <tr key={i}>
      <td className="break-me">{name}</td>
      <td>{value}</td>
    </tr>
  );

  const chartBoxProps = {
    className: 'report-chart',
    noDataMsg: __('No data available'),
    status: STATUS.RESOLVED,
    config: 'medium',
  };

  return (
    <Grid hasGutter>
      <GridItem span={4}>
        <table className="table table-bordered table-striped table-hover report-chart">
          <tbody>{statuses.map((label, v) => createRow(label, v))}</tbody>
          {totalStatuses.length ? (
            <tfoot>
              <tr>
                <th>{__('Total')}</th>
                <th>{totalStatuses[0][2]}</th>
              </tr>
            </tfoot>
          ) : null}
        </table>
      </GridItem>
      <GridItem span={4}>
        <ChartBox
          {...chartBoxProps}
          type="donut"
          chart={{ data: metricsChartData }}
          title={__('Report Metrics')}
        />
      </GridItem>
      <GridItem span={4}>
        <table className="table table-bordered table-striped table-hover report-chart">
          <tbody>
            {metricsChartData.map((label, t) => createRow(label, t))}
          </tbody>
          {totalTime.length ? (
            <tfoot>
              <tr>
                <th>{__('Total')}</th>
                <th>{parseFloat(totalTime[0][2].toFixed(4))}</th>
              </tr>
            </tfoot>
          ) : null}
        </table>
      </GridItem>
    </Grid>
  );
};

HostReportMetrics.propTypes = {
  metrics: PropTypes.shape({
    time: PropTypes.shape({
      values: PropTypes.array,
    }),
    resources: PropTypes.shape({
      values: PropTypes.array,
    }),
  }).isRequired,
};

export default HostReportMetrics;
