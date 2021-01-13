import { combineReducers } from 'redux';
import EmptyStateReducer from './Components/EmptyState/EmptyStateReducer';

const reducers = {
  foremanHostReports: combineReducers({
    emptyState: EmptyStateReducer,
  }),
};

export default reducers;
