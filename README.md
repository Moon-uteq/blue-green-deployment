# 🚀 Blue-Green Deployment Demo

Implementación completa de **Blue-Green Deployment** con React, Docker, Nginx y GitHub Actions, desplegado en DigitalOcean.

## 📋 Características

- ✅ **Pipeline CI/CD** con GitHub Actions
- 🐳 **Docker** con multi-stage build
- 📜 **Scripts Shell** automatizados
- 🔄 **Nginx** load balancer
- ☁️ **Deploy automático** a DigitalOcean
- ❤️ **Health checks** y monitoring
- 🎯 **Zero-downtime deployments**

## 🏗️ Arquitectura
```
GitHub → Actions → DigitalOcean Server
                        │
                   ┌─────────┐
                   │ Nginx   │ :8080
                   │ (LB)    │
                   └─────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
   ┌─────────┐     ┌─────────┐     ┌─────────┐
   │  Blue   │     │  Green  │     │ Switch  │
   │  :3001  │     │  :3002  │     │ Traffic │
   └─────────┘     └─────────┘     └─────────┘
```

## 🚀 Inicio Rápido

### 1. Configuración Local
```bash
# Clonar repositorio
git clone <tu-repo-url>
cd blue-green-deployment-demo

# Instalar dependencias
npm install

# Probar localmente
docker-compose up -d

# Acceder
http://localhost:8080  # Load Balancer
http://localhost:3001  # Blue environment
http://localhost:3002  # Green environment
```

### 2. Deploy a DigitalOcean

#### Configurar servidor:
```bash
# 1. Crear Droplet en DigitalOcean (Docker on Ubuntu)
# 2. Configurar SSH keys
# 3. Instalar dependencias adicionales si es necesario
```

#### Configurar GitHub Secrets:
```bash
# En GitHub → Settings → Secrets and variables → Actions
DO_SSH_PRIVATE_KEY=your-ssh-private-key
DO_SERVER_IP=your-server-ip
```

#### Deploy automático:
```bash
# Push a main branch o ejecutar workflow manual
git push origin main
```

## 📁 Estructura del Proyecto
```
├── .github/workflows/      # CI/CD Pipeline
│   └── deploy.yml
├── nginx/                  # Configuración Nginx
│   ├── default.conf       # Config contenedores
│   └── nginx.conf         # Config load balancer
├── scripts/                # Automatización
│   ├── deploy.sh          # Script deployment
│   ├── health-check.sh    # Verificación salud
│   └── switch.sh          # Cambio tráfico
├── src/                    # Código React
├── public/                 # Assets públicos
├── Dockerfile              # Configuración Docker
├── docker-compose.yml      # Orquestación
└── README.md
```

## 🔧 Comandos Disponibles

### Scripts de Deployment
```bash
# Deploy nueva versión
./scripts/deploy.sh v1.0.0 green

# Verificar salud
./scripts/health-check.sh green

# Cambiar tráfico
./scripts/switch.sh green
```

### Docker Commands
```bash
# Construir y ejecutar
docker-compose up -d

# Ver logs
docker-compose logs -f nginx-lb
docker-compose logs -f app-blue
docker-compose logs -f app-green

# Ver estado
docker-compose ps

# Detener
docker-compose down
```

## 🌐 Endpoints

| URL | Puerto | Descripción |
|-----|--------|-------------|
| `http://server-ip:8080` | 8080 | Load Balancer Principal |
| `http://server-ip:8080/status` | 8080 | Estado load balancer |
| `http://server-ip:3001` | 3001 | Blue environment |
| `http://server-ip:3002` | 3002 | Green environment |
| `http://server-ip:3001/health` | 3001 | Health check Blue |
| `http://server-ip:3002/health` | 3002 | Health check Green |

## 🚀 Proceso de Deployment

1. **Desarrollo**: Hacer cambios en código
2. **Push**: `git push origin main`
3. **CI/CD**: Pipeline automático ejecuta
4. **Build**: Construye imagen Docker
5. **Test**: Ejecuta pruebas
6. **Deploy**: Despliega a ambiente inactivo
7. **Health Check**: Verifica que funcione
8. **Switch** (manual): Cambia tráfico
9. **Monitor**: Verificar funcionamiento

## 🔄 Estrategia Blue-Green

### Estado Inicial
- **Blue**: Activo (100% tráfico)
- **Green**: Inactivo (0% tráfico)

### Durante Deployment
- **Blue**: Sigue activo
- **Green**: Nueva versión desplegada

### Después del Switch
- **Blue**: Inactivo (versión anterior)
- **Green**: Activo (nueva versión)

### Rollback (si necesario)
- **Switch rápido** de vuelta a Blue

## ⚙️ Configuración DigitalOcean

### Crear Droplet
```bash
# 1. Login a DigitalOcean
# 2. Create → Droplets
# 3. Choose: Docker on Ubuntu 22.04
# 4. Size: $6/month (2GB RAM) mínimo
# 5. Add SSH Key
# 6. Create Droplet
```

### Setup inicial en servidor
```bash
# Conectar por SSH
ssh root@your-server-ip

# Verificar Docker
docker --version
docker-compose --version

# Configurar firewall
ufw allow 22    # SSH
ufw allow 8080  # Load Balancer
ufw allow 3001  # Blue
ufw allow 3002  # Green
ufw enable

# Crear directorio proyecto
mkdir -p /opt/blue-green-app
```

## 🔍 Troubleshooting

### Pipeline falla
```bash
# Verificar secrets de GitHub
# Verificar conectividad SSH
# Revisar logs en Actions tab
```

### Contenedores no inician
```bash
# SSH al servidor
ssh root@your-server-ip
cd /opt/blue-green-app

# Ver logs
docker-compose logs

# Rebuild
docker-compose build --no-cache
```

### Health checks fallan
```bash
# Verificar manualmente
curl http://server-ip:3001/health
curl http://server-ip:3002/health

# Revisar configuración nginx
docker-compose exec nginx-lb cat /etc/nginx/nginx.conf
```

## 💰 Costos Estimados

- **DigitalOcean Droplet**: $6-12/mes
- **Bandwidth**: Incluido (1TB)
- **GitHub Actions**: 2000 minutos gratis/mes
- **Total**: ~$6-12/mes

## 👨‍💻 Desarrollo

### Local Development
```bash
npm start           # Modo desarrollo
npm test            # Ejecutar tests
npm run build       # Build producción
```

### Hacer cambios
```bash
# 1. Crear feature branch
git checkout -b feature/nueva-funcionalidad

# 2. Hacer cambios y commit
git add .
git commit -m "Add nueva funcionalidad"

# 3. Push y PR
git push origin feature/nueva-funcionalidad

# 4. Merge a main para deploy automático
```

## 📚 Recursos

- [Docker Documentation](https://docs.docker.com/)
- [DigitalOcean Tutorials](https://www.digitalocean.com/community/tutorials)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Blue-Green Deployment Pattern](https://martinfowler.com/bliki/BlueGreenDeployment.html)

## 🏆 Proyecto Universitario

**Universidad**: Universidad Tecnológica de Querétaro (UTEQ)  
**Materia**: Gestión de Procesos de Desarrollo de Software  
**Implementa**:
- Pipeline de CI/CD
- Dockerización
- Scripts de Shell
- Load Balancing con Nginx
- Deploy en la nube

---

¡Happy Deploying! 🚀✨