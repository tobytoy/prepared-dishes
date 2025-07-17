#!/bin/bash

# Create volumes for persistent data
podman volume create odoo-data
podman volume create odoo-db-data

# Create a pod for Odoo and PostgreSQL
podman pod create --name odoo-pod -p 8069:8069

# Run PostgreSQL container in the pod
podman run -d --pod odoo-pod \
  --name odoo-db \
  -v odoo-db-data:/var/lib/postgresql/data \
  -e POSTGRES_USER=odoo \
  -e POSTGRES_PASSWORD=odoo \
  -e POSTGRES_DB=postgres \
  docker.io/library/postgres:15

# Run Odoo container in the pod
podman run -d --pod odoo-pod \
  --name odoo-app \
  -v odoo-data:/var/lib/odoo \
  -e HOST=db \
  -e USER=odoo \
  -e PASSWORD=odoo \
  docker.io/library/odoo:18.0

echo "Odoo and PostgreSQL have been successfully set up in the pod 'odoo-pod'."
echo "Access Odoo at http://localhost:8069"


# podman run --replace -d --pod odoo-pod \
#   --name odoo-app \
#   -v odoo-data:/var/lib/odoo \
#   -e HOST=odoo-db \
#   -e USER=odoo \
#   -e PASSWORD=odoo \
#   docker.io/library/odoo:18.0

# podman run --replace -d --pod odoo-pod \
#   --name odoo-app \
#   -v odoo-data:/var/lib/odoo \
#   -e DB_HOST=odoo-db \
#   -e DB_PORT=5432 \
#   -e DB_USER=odoo \
#   -e DB_PASSWORD=odoo \
#   docker.io/library/odoo:18.0

