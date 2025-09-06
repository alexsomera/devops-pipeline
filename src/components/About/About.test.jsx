import React from 'react';
import { render } from '@testing-library/react';
import About from './About';

describe('About', () => {
  it('renderiza o componente About sem falhas', () => {
    const { container } = render(<About />);
    expect(container).toBeInTheDocument();
  });
});
