import { getControllerSearchProps } from 'foremanReact/constants';

export const HOST_REPORTS_SEARCH_PROPS = getControllerSearchProps(
  'host_reports'
);
export const HOSTS_PATH = '/hosts';
export const HOST_REPORTS_PATH = '/host_reports';
export const HOST_REPORTS_API_PATH =
  '/api/v2/host_reports?include_permissions=true';
export const HOST_REPORTS_API_PLAIN_PATH = '/api/v2/host_reports';

export const HOST_REPORT_REQUEST_KEY = 'HOST_REPORT';
export const HOST_REPORTS_API_REQUEST_KEY = 'HOST_REPORTS_API';

export const HOST_REPORT_DELETE_MODAL_ID = 'hostReportDeleteModal';

export const RAW_MSG_MODAL_ID = 'rawMsgModal';
