import React from 'react';
import { render } from '@testing-library/react';
import CarsList from './CarsList';

describe('CarsList', () => {
  it('renderiza o componente CarsList sem falhas', () => {
    const { container } = render(<CarsList />);
    expect(container).toBeInTheDocument();
  });
});
