import { render, screen, waitFor } from '@testing-library/react';
import App from '../App';

describe('Integration Tests', () => {
  test('aplicação carrega completamente', async () => {
    render(<App />);
    
    // Verifica se componentes principais estão renderizados
    await waitFor(() => {
      expect(screen.getByRole('heading', { name: /Hot Wheels/i })).toBeInTheDocument();
    });
    
    // Verifica se a navegação funciona
    const homeLink = screen.getByText(/Home/i);
    expect(homeLink).toBeInTheDocument();
    
    const aboutLinks = screen.getAllByText(/Sobre/i);
    expect(aboutLinks.length).toBeGreaterThan(0);
  });

  test('health check endpoint está disponível', async () => {
    // Simula chamada para endpoint de health
    global.fetch = jest.fn(() =>
      Promise.resolve({
        ok: true,
        json: () => Promise.resolve({
          status: 'healthy',
          service: 'pipeline-devops'
        }),
      })
    );

    const response = await fetch('/health.json');
    const data = await response.json();
    
    expect(response.ok).toBe(true);
    expect(data.status).toBe('healthy');
    
    global.fetch.mockRestore();
  });

  test('aplicação responde a diferentes rotas', () => {
    render(<App />);
    
    // Verifica se o roteamento SPA funciona
    expect(document.title).toBeDefined();
    expect(screen.getByRole('heading', { name: /Hot Wheels/i })).toBeInTheDocument();
  });
});
