# prepared-dishes
For quick prepare server by podman.

## podman install

```bash
sudo apt update
sudo apt install -y podman
pip install podman-compose

```

## odoo

```bash
# Go to project docker folder
echo "password" > ./docker/odoo_pg_pass
# Go to docker folder
docker-compose -f docker/compose.yaml up -d 
```

## wordpress

