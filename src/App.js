import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [environment, setEnvironment] = useState('Unknown');
  const [version] = useState('8.0.0');
  const [timestamp, setTimestamp] = useState('');
  const [isAnimating, setIsAnimating] = useState(false);

  useEffect(() => {
    // Get environment from environment variable or default
    const env = process.env.REACT_APP_ENVIRONMENT || process.env.ENVIRONMENT || 'development';
    setEnvironment(env);
    
    // Set build timestamp
    setTimestamp(new Date().toLocaleString());

    // Trigger animation on mount
    setTimeout(() => setIsAnimating(true), 100);
  }, []);

  const getEnvironmentConfig = () => {
    switch (environment.toLowerCase()) {
      case 'blue':
        return {
          color: '#1e3a8a',
          gradient: 'linear-gradient(135deg, #1e40af 0%, #3b82f6 50%, #60a5fa 100%)',
          icon: '🌊',
          subtitle: 'Blue Ocean Deployment'
        };
      case 'green':
        return {
          color: '#166534',
          gradient: 'linear-gradient(135deg, #15803d 0%, #22c55e 50%, #4ade80 100%)',
          icon: '🌿',
          subtitle: 'Green Forest Deployment'
        };
      case 'production':
        return {
          color: '#7c2d12',
          gradient: 'linear-gradient(135deg, #dc2626 0%, #f59e0b 50%, #fbbf24 100%)',
          icon: '🚀',
          subtitle: 'Production Ready'
        };
      default:
        return {
          color: '#374151',
          gradient: 'linear-gradient(135deg, #4b5563 0%, #6b7280 50%, #9ca3af 100%)',
          icon: '⚙️',
          subtitle: 'Development Environment'
        };
    }
  };

  const config = getEnvironmentConfig();

  const handleRefresh = () => {
    window.location.reload();
  };

  return (
    <div className="app-container">
      {/* Animated background */}
      <div className="animated-bg" style={{ background: config.gradient }}>
        <div className="floating-shapes">
          <div className="shape shape-1"></div>
          <div className="shape shape-2"></div>
          <div className="shape shape-3"></div>
          <div className="shape shape-4"></div>
        </div>
      </div>

      {/* Main content */}
      <div className={`main-content ${isAnimating ? 'animate-in' : ''}`}>
        {/* Header Card */}
        <div className="environment-card">
          <div className="card-header">
            <div className="env-icon">{config.icon}</div>
            <div className="env-title">
              <h1>{environment.toUpperCase()}</h1>
              <p className="env-subtitle">{config.subtitle}</p>
            </div>
          </div>
          
          <div className="deployment-status">
            <div className="status-indicator">
              <div className="pulse-dot" style={{ backgroundColor: config.color }}></div>
              <span>ACTIVE DEPLOYMENT</span>
            </div>
          </div>
        </div>

        {/* Info Grid */}
        <div className="info-grid">
          <div className="info-card">
            <div className="info-icon">📦</div>
            <div className="info-content">
              <h3>Version</h3>
              <p className="info-value">{version}</p>
            </div>
          </div>

          <div className="info-card">
            <div className="info-icon">⏰</div>
            <div className="info-content">
              <h3>Deployed At</h3>
              <p className="info-value">{timestamp}</p>
            </div>
          </div>

          <div className="info-card">
            <div className="info-icon">🏗️</div>
            <div className="info-content">
              <h3>Build System</h3>
              <p className="info-value">GitHub Actions</p>
            </div>
          </div>

          <div className="info-card">
            <div className="info-icon">🐳</div>
            <div className="info-content">
              <h3>Container</h3>
              <p className="info-value">Docker + Nginx</p>
            </div>
          </div>
        </div>

        {/* Action Button */}
        <div className="action-section">
          <button className="refresh-btn" onClick={handleRefresh}>
            <span className="btn-icon">🔄</span>
            Refresh Status
          </button>
        </div>

        {/* Footer */}
        <footer className="app-footer">
          <div className="footer-content">
            <div className="tech-stack">
              <span className="tech-item">React</span>
              <span className="tech-separator">•</span>
              <span className="tech-item">Docker</span>
              <span className="tech-separator">•</span>
              <span className="tech-item">Nginx</span>
              <span className="tech-separator">•</span>
              <span className="tech-item">CI/CD</span>
            </div>
            <p className="footer-text">Blue-Green Deployment System by Moon</p>
          </div>
        </footer>
      </div>
    </div>
  );
}

export default App;