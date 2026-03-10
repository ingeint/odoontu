#!/usr/bin/env bash
set -Eeo pipefail

echo "🚀 Starting Odoo container..."

# =========================
# Variables por defecto
# =========================
DB_HOST=${DB_HOST:-db}
DB_PORT=${DB_PORT:-5432}
DB_NAME=${DB_NAME:-odoo}
DB_USER=${DB_USER:-odoo}
DB_PASSWORD=${DB_PASSWORD:-odoo}

ADMIN_PASSWD=${ADMIN_PASSWD:-admin}
INSTALL_MODULES=${INSTALL_MODULES:-base}
WITHOUT_DEMO=${WITHOUT_DEMO:-all}
LOAD_LANGUAGE=${LOAD_LANGUAGE:-es_VE}

ODOO_TEMPLATE=${ODOO_TEMPLATE:-/home/odoo/etc/odoo.template}
ODOO_RC=${ODOO_RC:-/home/odoo/etc/conf/odoo.conf}
ODOO_DATA=${ODOO_DATA:-/var/lib/odoo}

if [ -n "${ADDONS_PATH}" ]; then
    EFFECTIVE_ADDONS_PATH="${ADDONS_PATH}"
else
    EFFECTIVE_ADDONS_PATH="/odoo/odoo/addons,/odoo/addons,/mnt/extra-addons"
fi

export DB_HOST DB_PORT DB_NAME DB_USER DB_PASSWORD ADMIN_PASSWD
export ADDONS_PATH="${EFFECTIVE_ADDONS_PATH}"

echo "🧩 ADDONS_PATH: ${ADDONS_PATH}"

# =========================
# Fix permissions
# =========================
mkdir -p "${ODOO_DATA}" "${ODOO_DATA}/sessions" /home/odoo/etc/conf /var/log/odoo
chown -R odoo:odoo "${ODOO_DATA}" /home/odoo /var/log/odoo /mnt/extra-addons || true

# =========================
# Validar template
# =========================
if [ ! -f "${ODOO_TEMPLATE}" ]; then
    echo "❌ ERROR: No existe ${ODOO_TEMPLATE}"
    exit 1
fi

# =========================
# Generar odoo.conf
# =========================
echo "⚙️ Generando odoo.conf..."

envsubst '${ADMIN_PASSWD} ${DB_HOST} ${DB_PORT} ${DB_USER} ${DB_PASSWORD} ${DB_NAME} ${ADDONS_PATH}' \
    < "${ODOO_TEMPLATE}" \
    > "${ODOO_RC}"

chown odoo:odoo "${ODOO_RC}"

echo "📄 Archivo de configuración generado en ${ODOO_RC}:"
cat "${ODOO_RC}"

# =========================
# Esperar PostgreSQL
# =========================
echo "⏳ Esperando que la base de datos esté lista en ${DB_HOST}:${DB_PORT}..."
if ! wait-for-psql.py \
        --db_host="${DB_HOST}" \
        --db_port="${DB_PORT}" \
        --db_user="${DB_USER}" \
        --db_password="${DB_PASSWORD}" \
        --db_name="${DB_NAME}"; then
    echo "❌ Error: No se pudo conectar a la base de datos en ${DB_HOST}:${DB_PORT}"
    exit 1
fi

echo "✅ PostgreSQL disponible"

# =========================
# Verificar si la base ya está inicializada
# =========================
echo "🔍 Verificando si la base de datos ${DB_NAME} está inicializada..."

DB_INITIALIZED=$(PGPASSWORD="${DB_PASSWORD}" psql \
    -h "${DB_HOST}" \
    -p "${DB_PORT}" \
    -U "${DB_USER}" \
    -d "${DB_NAME}" \
    -tAc "SELECT 1 FROM ir_module_module WHERE name = 'base' AND state = 'installed';" || true)

if [ "${DB_INITIALIZED}" != "1" ]; then
    echo "🚀 Inicializando la base de datos con los módulos: ${INSTALL_MODULES}..."
    exec gosu odoo /opt/venv/bin/python3 /odoo/odoo-bin \
        -c "${ODOO_RC}" \
        -i "${INSTALL_MODULES}" \
        --without-demo="${WITHOUT_DEMO}" \
        --load-language="${LOAD_LANGUAGE}"
else
    echo "✅ La base de datos ya está inicializada."
    exec gosu odoo /opt/venv/bin/python3 /odoo/odoo-bin -c "${ODOO_RC}"
fi
