#!/usr/bin/env bash

set -Eeo pipefail

ODOO_RC="/etc/odoo/conf/odoo.conf"
TEMPLATE="/etc/odoo/conf/odoo.template"

# Environment Variables
DB_HOST=${DB_HOST:-db}
DB_PORT=${DB_PORT:-5432}
DB_NAME=${DB_NAME:-odoo}
DB_USER=${DB_USER:-odoo}
DB_PASS=${DB_PASSWORD:-odoo}
ADMIN_PASSWD=${ADMIN_PASSWD:-admin}
INSTALL_MODULES=${INSTALL_MODULES:-base}
WITHOUT_DEMO=${WITHOUT_DEMO:-all}
LOAD_LANGUAGE=${LOAD_LANGUAGE:-es_VE}

# Validar si hay permiso para escribir
touch "$ODOO_RC" 2>/dev/null || echo "❌ No puedo escribir en $ODOO_RC"

# Verificar si el archivo está vacío o inválido
if [ ! -s "$ODOO_RC" ] || ! grep -q "^\[options\]" "$ODOO_RC"; then
  echo "🔄 Generando nuevo archivo de configuración en $ODOO_RC"

  if [ -f "$TEMPLATE" ]; then
    sed -e "s|\${ADMIN_PASSWD}|${ADMIN_PASSWD}|g" \
        -e "s|\${DB_HOST}|${DB_HOST}|g" \
        -e "s|\${DB_PORT}|${DB_PORT}|g" \
        -e "s|\${DB_USER}|${DB_USER}|g" \
        -e "s|\${DB_PASSWORD}|${DB_PASSWORD}|g" \
        -e "s|\${DB_NAME}|${DB_NAME}|g" \
        "$TEMPLATE" > "$ODOO_RC"
  else
    echo "❌ Error: No se encontró la plantilla $TEMPLATE"
    exit 1
  fi
else
  echo "✅ Archivo de configuración ya existe y tiene contenido válido: $ODOO_RC"
fi

# Esperar base de datos
echo "⏳ Esperando que la base de datos esté lista..."
if ! wait-for-psql.py --db_host=$DB_HOST --db_port=$DB_PORT --db_user=$DB_USER --db_password=$DB_PASSWORD; then
    echo "❌ Error: No se pudo conectar a la base de datos en $DB_HOST:$DB_PORT"
    exit 1
fi

# Verificar si la base de datos está inicializada
echo "🔍 Verificando si la base de datos está inicializada..."
if ! PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c \
   "SELECT 1 FROM ir_module_module WHERE name='base' AND state='installed';" | grep -q 1; then
    echo "🚀 Inicializando la base de datos con los módulos: $INSTALL_MODULES"
    exec odoo -c "$ODOO_RC" -i $INSTALL_MODULES --without-demo=$WITHOUT_DEMO --load-language=$LOAD_LANGUAGE
else
    echo "✅ La base de datos ya está inicializada."
    exec odoo -c "$ODOO_RC"
fi

