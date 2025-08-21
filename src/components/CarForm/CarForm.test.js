import React from 'react';
import { render } from '@testing-library/react';
import CarForm from './CarForm';

describe('CarForm', () => {
  it('renderiza o componente CarForm sem falhas', () => {
    const { container } = render(<CarForm />);
    expect(container).toBeInTheDocument();
  });
});