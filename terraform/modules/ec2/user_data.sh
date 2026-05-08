#!/bin/bash
set -euo pipefail
exec > >(tee /var/log/user-data.log | logger -t user-data) 2>&1

echo "=== Starting bootstrap for ${project_name} ==="

# System update & dependencies 
dnf update -y
dnf install -y docker nginx git

# ── Docker setup ───────────────────────────────────────────────
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

# Docker Compose plugin
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# ── App directory ─────────────────────────────────────────────────
mkdir -p /opt/${project_name}
cd /opt/${project_name}

# ── Prometheus config ─────────────────────────────────────────────
mkdir -p monitoring/prometheus
cat > monitoring/prometheus/prometheus.yml <<'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'app'
    static_configs:
      - targets: ['app:${app_port}']
    metrics_path: /metrics
EOF

# ── Docker Compose ────────────────────────────────────────────────
cat > docker-compose.yml <<EOF
version: '3.8'

services:
  app:
    image: ${dockerhub_username}/${project_name}:latest
    container_name: app
    restart: unless-stopped
    ports:
      - "127.0.0.1:${app_port}:${app_port}"
    environment:
      - NODE_ENV=${environment}
      - PORT=${app_port}
    networks:
      - monitoring

  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: unless-stopped
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.retention.time=7d'
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: unless-stopped
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=devops2024
      - GF_USERS_ALLOW_SIGN_UP=false
    volumes:
      - grafana_data:/var/lib/grafana
    networks:
      - monitoring

  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    restart: unless-stopped
    pid: host
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
    networks:
      - monitoring

volumes:
  prometheus_data:
  grafana_data:

networks:
  monitoring:
    driver: bridge
EOF

# ── Start all containers ──────────────────────────────────────────
docker compose pull
docker compose up -d

# ── Nginx reverse proxy ───────────────────────────────────────────
cat > /etc/nginx/conf.d/${project_name}.conf <<EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass         http://127.0.0.1:${app_port};
        proxy_http_version 1.1;
        proxy_set_header   Host              \$host;
        proxy_set_header   X-Real-IP         \$remote_addr;
        proxy_set_header   X-Forwarded-For   \$proxy_add_x_forwarded_for;
    }

    location /health {
        proxy_pass http://127.0.0.1:${app_port}/health;
    }
}
EOF

# Remove default nginx config
rm -f /etc/nginx/conf.d/default.conf

systemctl enable nginx
systemctl restart nginx

echo "=== Bootstrap complete ==="