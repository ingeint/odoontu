#!/usr/bin/env bash
set -Eeo pipefail

# Variables de entorno predeterminadas
DB_HOST=${DB_HOST:-db}
DB_PORT=${DB_PORT:-5432}
DB_NAME=${DB_NAME:-odoo}
DB_USER=${DB_USER:-odoo}
DB_PASSWORD=${DB_PASSWORD:-odoo}
ADMIN_PASSWD=${ADMIN_PASSWD:-admin}
INSTALL_MODULES=${INSTALL_MODULES:-base}
WITHOUT_DEMO=${WITHOUT_DEMO:-all}
LOAD_LANGUAGE=${LOAD_LANGUAGE:-es_VE}
ODOO_RC=${ODOO_RC:-/etc/odoo/conf/odoo.conf}

ADDONS_PATH="/odoo/odoo/addons,/odoo/addons,/mnt/extra-addons"
echo "🧩 ADDONS_PATH: $ADDONS_PATH"

# Generar el archivo odoo.conf dinámicamente
sed -e "s|\${ADMIN_PASSWD}|${ADMIN_PASSWD}|g" \
    -e "s|\${DB_HOST}|${DB_HOST}|g" \
    -e "s|\${DB_PORT}|${DB_PORT}|g" \
    -e "s|\${DB_USER}|${DB_USER}|g" \
    -e "s|\${DB_PASSWORD}|${DB_PASSWORD}|g" \
    -e "s|\${DB_NAME}|${DB_NAME}|g" \
    -e "s|\${ADDONS_PATH}|${ADDONS_PATH}|g" \
    /etc/odoo/odoo.template > "$ODOO_RC"

echo "📄 Archivo de configuración generado:"
cat "$ODOO_RC"

# Esperar a que la base de datos esté lista
echo "⏳ Esperando que la base de datos esté lista..."
if ! wait-for-psql.py --db_host=$DB_HOST --db_port=$DB_PORT --db_user=$DB_USER --db_password=$DB_PASSWORD --db_name=$DB_NAME; then
    echo "❌ Error: No se pudo conectar a la base de datos en $DB_HOST:$DB_PORT"
    exit 1
fi

# Verificar si la base está inicializada
echo "🔍 Verificando si la base de datos está inicializada..."
if ! PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT 1 FROM ir_module_module WHERE name='base' AND state='installed';" | grep -q 1; then
    echo "🚀 Inicializando la base de datos con los módulos: $INSTALL_MODULES..."
    exec odoo -c "$ODOO_RC" -i $INSTALL_MODULES --without-demo=$WITHOUT_DEMO --load-language=$LOAD_LANGUAGE
else
    echo "✅ La base de datos ya está inicializada."
    exec odoo -c "$ODOO_RC"
fi

