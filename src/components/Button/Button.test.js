import React from 'react';
import { render } from '@testing-library/react';
import Button from './Button';

describe('Button', () => {
  it('renderiza o componente Button sem falhas', () => {
    const { container } = render(<Button>Teste</Button>);
    expect(container).toBeInTheDocument();
  });
});
