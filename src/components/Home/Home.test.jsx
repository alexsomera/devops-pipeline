import React from 'react';
import { render } from '@testing-library/react';
import Home from './Home';

describe('Home', () => {
  it('renderiza o componente Home sem falhas', () => {
    const { container } = render(<Home />);
    expect(container).toBeInTheDocument();
  });
});
