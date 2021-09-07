export const msgLevelClasses = level => {
  let tag;
  switch (level) {
    case 'notice':
      tag = 'info';
      break;
    case 'warning':
      tag = 'warning';
      break;
    case 'err':
      tag = 'danger';
      break;
    default:
      tag = 'default';
  }
  return `label label-${tag} result-filter-tag`;
};
