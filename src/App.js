import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [environment, setEnvironment] = useState('Unknown');
  const [version] = useState('8.1.0');
  const [timestamp, setTimestamp] = useState('');
  const [uptime, setUptime] = useState(0);

  useEffect(() => {
    // Obtener el ambiente desde las variables de entorno
    // Durante el BUILD de Docker, las variables se inyectan en el código
    const env = process.env.REACT_APP_ENVIRONMENT || 'Unknown';
    setEnvironment(env);
    
    // Establecer la marca de tiempo de cuando se construyó
    setTimestamp(new Date().toLocaleString());

    // Simular un contador de tiempo activo (uptime)
    // Esto cuenta cuántos segundos lleva la app abierta
    const interval = setInterval(() => {
      setUptime(prev => prev + 1);
    }, 1000);

    return () => clearInterval(interval); // Limpiar cuando el componente se desmonte
  }, []);

  // Función que retorna el color según el ambiente
  const getEnvironmentColor = () => {
    switch (environment.toLowerCase()) {
      case 'blue':
        return '#0066cc';
      case 'green':
        return '#00cc66';
      case 'production':
        return '#9c27b0';
      default:
        return '#607d8b';
    }
  };

  // Función que convierte segundos en formato legible (minutos y segundos)
  const formatUptime = (seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return ${mins}m ${secs}s;
  };

  return (
    <div className="App">
      {/* Barra superior con el logo y título */}
      <nav className="navbar" style={{ backgroundColor: getEnvironmentColor() }}>
        <div className="navbar-content">
          <div className="logo-section">
            <div className="logo-circle"></div>
            <span className="logo-text">Blue-Green Deploy</span>
          </div>
          <div className="environment-badge" style={{ borderColor: getEnvironmentColor() }}>
            {environment.toUpperCase()}
          </div>
        </div>
      </nav>

      {/* Contenedor principal con todas las secciones */}
      <div className="container">
        {/* Sección de bienvenida */}
        <section className="welcome-section">
          <h1 className="main-title">Sistema de Despliegue</h1>
          <p className="subtitle">Monitoreo en tiempo real de tu aplicación</p>
        </section>

        {/* Grid de tarjetas con información */}
        <div className="cards-grid">
          {/* Tarjeta 1: Estado del Sistema */}
          <div className="card status-card">
            <div className="card-icon" style={{ backgroundColor: getEnvironmentColor() }}>
              <span className="icon">✓</span>
            </div>
            <h3 className="card-title">Estado del Sistema</h3>
            <div className="status-indicator">
              <span className="status-dot active"></span>
              <span className="status-text">Operativo</span>
            </div>
            <p className="card-description">
              Todos los servicios funcionando correctamente
            </p>
          </div>

          {/* Tarjeta 2: Información de Versión */}
          <div className="card version-card">
            <div className="card-icon" style={{ backgroundColor: getEnvironmentColor() }}>
              <span className="icon">v</span>
            </div>
            <h3 className="card-title">Versión Actual</h3>
            <div className="version-number">{version}</div>
            <p className="card-description">
              Última actualización desplegada
            </p>
          </div>

          {/* Tarjeta 3: Tiempo Activo */}
          <div className="card uptime-card">
            <div className="card-icon" style={{ backgroundColor: getEnvironmentColor() }}>
              <span className="icon">⏱</span>
            </div>
            <h3 className="card-title">Tiempo Activo</h3>
            <div className="uptime-display">{formatUptime(uptime)}</div>
            <p className="card-description">
              Tiempo desde el último despliegue
            </p>
          </div>

          {/* Tarjeta 4: Información de Despliegue */}
          <div className="card deploy-card">
            <div className="card-icon" style={{ backgroundColor: getEnvironmentColor() }}>
              <span className="icon">🚀</span>
            </div>
            <h3 className="card-title">Último Despliegue</h3>
            <div className="deploy-time">{timestamp}</div>
            <p className="card-description">
              Fecha y hora del deploy
            </p>
          </div>
        </div>

        {/* Sección de información técnica */}
        <div className="tech-info">
          <h2 className="tech-title">Stack Tecnológico</h2>
          <div className="tech-stack">
            <div className="tech-item">
              <div className="tech-icon">⚛️</div>
              <span>React</span>
            </div>
            <div className="tech-item">
              <div className="tech-icon">🐳</div>
              <span>Docker</span>
            </div>
            <div className="tech-item">
              <div className="tech-icon">🔧</div>
              <span>Nginx</span>
            </div>
            <div className="tech-item">
              <div className="tech-icon">⚙️</div>
              <span>GitHub Actions</span>
            </div>
            <div className="tech-item">
              <div className="tech-icon">🌊</div>
              <span>Digital Ocean</span>
            </div>
          </div>
        </div>

        {/* Pie de página */}
        <footer className="footer">
          <p>Estrategia Blue-Green Deployment</p>
          <p>Despliegues sin tiempo de inactividad • Rollback instantáneo</p>
        </footer>
      </div>
    </div>
  );
}

export default App;