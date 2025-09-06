import { render } from '@testing-library/react';
import App from './App.jsx';

test('renderiza o componente App sem falhas', () => {
  const { container } = render(<App />);
  expect(container).toBeInTheDocument();
});
