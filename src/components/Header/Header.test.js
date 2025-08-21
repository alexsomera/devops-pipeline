import React from 'react';
import { render } from '@testing-library/react';
import Header from './Header';

describe('Header', () => {
  it('renderiza o componente Header sem falhas', () => {
    const { container } = render(<Header />);
    expect(container).toBeInTheDocument();
  });
});
