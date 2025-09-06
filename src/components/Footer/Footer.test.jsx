import React from 'react';
import { render } from '@testing-library/react';
import Footer from './Footer';

describe('Footer', () => {
  it('renderiza o componente Footer sem falhas', () => {
    const { container } = render(<Footer />);
    expect(container).toBeInTheDocument();
  });
});
