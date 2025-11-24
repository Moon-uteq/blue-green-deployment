# Multi-stage build para optimizar la imagen
FROM node:18-alpine as build

WORKDIR /app

# Copiar package.json y package-lock.json
COPY package*.json ./

# Instalar dependencias
RUN npm install --omit=dev

# Copiar código fuente
COPY . .

# Build de la aplicación (React usa las variables de entorno en runtime)
RUN npm run build

# Etapa de producción con nginx
FROM nginx:alpine

# Copiar los archivos build al directorio de nginx
COPY --from=build /app/build /usr/share/nginx/html

# Copiar configuración custom de nginx
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Script para inyectar variables en runtime
RUN echo '#!/bin/sh' > /docker-entrypoint.d/99-inject-env.sh && \
    echo 'if [ ! -z "$REACT_APP_ENVIRONMENT" ]; then' >> /docker-entrypoint.d/99-inject-env.sh && \
    echo '  sed -i "s/development/$REACT_APP_ENVIRONMENT/g" /usr/share/nginx/html/static/js/*.js' >> /docker-entrypoint.d/99-inject-env.sh && \
    echo 'fi' >> /docker-entrypoint.d/99-inject-env.sh && \
    chmod +x /docker-entrypoint.d/99-inject-env.sh

# Exponer puerto
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# Comando por defecto
CMD ["nginx", "-g", "daemon off;"]