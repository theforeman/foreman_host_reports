import { testComponentSnapshotsWithFixtures } from '@theforeman/test';
import HostReportsIndexPage from '../IndexPage';

const fixtures = {
  'render with minimal props': {
    search: '',
    history: { location: { search: '' } },
    hostId: '1',
    fetchAndPush: jest.fn(),
    reloadWithSearch: jest.fn(),
    isLoading: false,
    hasError: false,
    hasData: true,
    itemCount: 1,
    canCreate: true,
    sort: {},
    page: 1,
    perPage: 20,
    reports: [
      {
        id: '1',
        hostId: '1',
        hostName: 'foreman.example.com',
        proxyId: '1',
        proxyName: 'foreman.example.com',
        format: 'plain',
        reportedAt: '2021-01-19T12:34:02.841645028Z',
        change: 0,
        nochange: 0,
        failure: 0,
      },
    ],
  },
};

describe('HostReportsIndexPage', () => {
  describe('redering', () =>
    testComponentSnapshotsWithFixtures(HostReportsIndexPage, fixtures));
});
