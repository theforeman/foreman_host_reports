import { registerRoutes } from 'foremanReact/routes/RoutingService';
import { registerFills } from './fills';
import ForemanHostReportsRoutes from './src/Router/routes';

registerRoutes('foreman_host_reports', ForemanHostReportsRoutes);
registerFills();
