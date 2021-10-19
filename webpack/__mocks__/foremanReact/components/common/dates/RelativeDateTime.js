import React from 'react';

const RelativeDateTime = (date, defaultValue, context) => (
  <span>{defaultValue || date}</span>
);

export default RelativeDateTime;
