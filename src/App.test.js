import { render, screen } from '@testing-library/react';
import App from './App';

test('renders blue green deployment text', () => {
  render(<App />);
  const linkElement = screen.getByText(/Blue-Green Deployment Demo/i);
  expect(linkElement).toBeInTheDocument();
});