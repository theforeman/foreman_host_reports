/* eslint-disable camelcase */
/* eslint-disable react/prop-types */
import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import {
  Dropdown,
  DropdownItem,
  KebabToggle,
  FlexItem,
  Flex,
  Tooltip,
} from '@patternfly/react-core';
import {
  ExclamationCircleIcon,
  SyncAltIcon,
  CheckCircleIcon,
  BanIcon,
  TagIcon,
} from '@patternfly/react-icons';
import { openConfirmModal } from 'foremanReact/components/ConfirmModal';
import { APIActions } from 'foremanReact/redux/API';
import { translate as __ } from 'foremanReact/common/I18n';
import { reportToShowFormatter } from '../../Router/HostReports/IndexPage/Components/HostReportsTable/Components/Formatters';

const FailedIcon = ({ label, withMargin = false }) => (
  <span style={withMargin ? { marginRight: '15px' } : {}}>
    <ExclamationCircleIcon color="var(--pf-global--palette--red-100)" /> {label}
  </span>
);

const ChangedIcon = ({ label, withMargin = false }) => (
  <span style={withMargin ? { marginRight: '15px' } : {}}>
    <SyncAltIcon color="var(--pf-global--palette--orange-300)" /> {label}
  </span>
);

const NochangeIcon = ({ label }) => (
  <>
    <CheckCircleIcon color="var(--pf-global--success-color--100)" /> {label}
  </>
);

export const statusSummaryFormatter = ({ change, nochange, failure }) => {
  const summary = [];
  if (failure)
    summary.push(<FailedIcon key="failed" label={failure} withMargin />);
  if (change)
    summary.push(<ChangedIcon key="changed" label={change} withMargin />);
  if (nochange) summary.push(<NochangeIcon key="nochange" label={nochange} />);
  return summary.length ? summary : '--';
};

export const globalStatusFormatter = ({ status }) => {
  switch (status) {
    case 'failure':
      return <FailedIcon label={__('Failed')} />;
    case 'change':
      return <ChangedIcon label={__('Changed')} />;
    case 'nochange':
      return <NochangeIcon label={__('Unchanged')} />;
    default:
      return (
        <>
          <BanIcon /> {__('Empty')}
        </>
      );
  }
};

export const keywordsFormatter = ({ keywords = [] }) => (
  <>
    <Tooltip content={<div>{keywords.join(',\n')}</div>}>
      <TagIcon color={keywords.length ? '#6a6e73' : '#d2d2d2'} />{' '}
      {keywords.length}
    </Tooltip>
  </>
);

export const ActionFormatter = ({ id, can_delete }, fetchReports) => {
  const [isOpen, setOpen] = useState(false);
  const dispatch = useDispatch();
  const dispatchConfirm = () => {
    dispatch(
      openConfirmModal({
        isWarning: true,
        title: __('Delete report?'),
        confirmButtonText: __('Delete report'),
        onConfirm: () =>
          dispatch(
            APIActions.delete({
              url: `/api/v2/host_reports/${id}`,
              key: `report-${id}-DELETE`,
              successToast: success => __('Report was successfully deleted'),
              errorToast: error =>
                __(`There was some issue deleting the report: ${error}`),
              handleSuccess: fetchReports,
            })
          ),
        message: __(
          'Are you sure you want to delete this report? This action is irreversible.'
        ),
      })
    );
  };
  const dropdownItems = [
    <DropdownItem
      key="action"
      component="button"
      onClick={dispatchConfirm}
      disabled={!can_delete}
    >
      {__('Delete')}
    </DropdownItem>,
  ];
  return (
    <Flex>
      <FlexItem align={{ default: 'alignRight' }}>
        <Dropdown
          onSelect={v => setOpen(!v)}
          toggle={<KebabToggle onToggle={setOpen} id="toggle-action" />}
          isOpen={isOpen}
          isPlain
          dropdownItems={dropdownItems}
        />
      </FlexItem>
    </Flex>
  );
};

export const getColumns = fetchReports => [
  {
    title: __('Reported at'),
    formatter: ({ reported_at, can_view, id }) =>
      reportToShowFormatter()(reported_at, {
        rowData: { canEdit: can_view, id },
      }),
    width: 25,
  },
  {
    title: __('Status'),
    formatter: globalStatusFormatter,
    width: 25,
  },
  {
    title: __('Summary'),
    formatter: statusSummaryFormatter,
    width: 25,
  },
  { title: __('Keywords'), formatter: keywordsFormatter, width: 15 },
  {
    title: null,
    formatter: data => ActionFormatter(data, fetchReports),
    width: 10,
  },
];
