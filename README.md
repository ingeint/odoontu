# Docker de Odoo sobre ubuntu 20.04

## Tags

-	[`13.0`](https://github.com/ingeint/odoolec/tree/master/7.1)

## Otros links

- [Localización Ecuatoriana para Odoo](https://github.com/ingeint/odoolec)

## Comandos

```
docker build -t odoontu:13.0 ./13.0
docker-compose up -d
```

## Docker compose

```
version: '3.7'

services:
  postgres:
    image: postgres:12
    environment:
      - TZ=America/Guayaquil
      - POSTGRES_DB=postgres
      - POSTGRES_USER=odoo
      - POSTGRES_PASSWORD=odoo
    volumes:
      - odoo_data:/var/lib/postgresql/data
    ports:
      - 5432:5432
    networks:
      odoo_network:

  odoo:
    image: odoontu:13.0
    environment:
      - TZ=America/Guayaquil
    volumes:
      - odoo_filestore:/var/lib/odoo
    ports:
      - 8069:8069
    networks:
      odoo_network:

networks:
  odoo_network:

volumes:
  odoo_data:
  odoo_filestore:
```
