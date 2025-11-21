import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [environment, setEnvironment] = useState('Unknown');
  const [version] = useState('1.1.0');
  const [timestamp, setTimestamp] = useState('');

  useEffect(() => {
    // Get environment from environment variable or default
    const env = process.env.REACT_APP_ENVIRONMENT || process.env.ENVIRONMENT || 'development';
    setEnvironment(env);
    
    // Set build timestamp
    setTimestamp(new Date().toLocaleString());
  }, []);

  const getEnvironmentColor = () => {
    switch (environment.toLowerCase()) {
      case 'blue':
        return '#007bff';
      case 'green':
        return '#28a745';
      case 'production':
        return '#17a2b8';
      default:
        return '#6c757d';
    }
  };

  return (
    <div className="App">
      <header className="App-header" style={{ backgroundColor: getEnvironmentColor() }}>
        <div className="environment-banner">
          <h1>🚀 Blue-Green Deployment Demo</h1>
          <div className="environment-info">
            <div className="env-badge" style={{ 
              backgroundColor: 'rgba(255,255,255,0.2)',
              padding: '10px 20px',
              borderRadius: '25px',
              margin: '20px 0'
            }}>
              <h2>Environment: {environment.toUpperCase()}</h2>
              <p>Version: {version}</p>
              <p>Deployed at: {timestamp}</p>
            </div>
          </div>
        </div>
        
        <div className="content-section">
          <h3>✅ Features Demonstrated:</h3>
          <ul style={{ textAlign: 'left', maxWidth: '600px' }}>
            <li>🐳 Docker containerization</li>
            <li>🔄 Blue-Green deployment strategy</li>
            <li>📋 Nginx load balancing</li>
            <li>🛠️ Shell scripts automation</li>
            <li>🚀 GitHub Actions CI/CD pipeline</li>
            <li>❤️ Health checks and monitoring</li>
          </ul>

          <div className="demo-buttons">
            <button 
              className="demo-btn"
              onClick={() => alert(`Currently running on ${environment} environment!`)}
            >
              Check Current Environment
            </button>
            
            <button 
              className="demo-btn secondary"
              onClick={() => window.open('/health', '_blank')}
            >
              Health Check
            </button>
          </div>
        </div>

        <div className="deployment-info">
          <h4>🔧 Deployment Commands:</h4>
          <div className="command-box">
            <code>./scripts/deploy.sh v1.0.0 green</code>
            <br />
            <code>./scripts/switch.sh green</code>
          </div>
        </div>

        <footer style={{ marginTop: '40px', opacity: '0.8' }}>
          <p>Blue-Green Deployment Implementation</p>
          <p>Built with React + Docker + Nginx + GitHub Actions</p>
        </footer>
      </header>
    </div>
  );
}

export default App;