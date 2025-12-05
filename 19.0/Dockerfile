FROM ubuntu:24.04

ENV ODOO_VERSION=19.0
ENV ODOO_HOME=/odoo
ENV ODOO_ETC=/etc/odoo
ENV ODOO_CONF_DIR=$ODOO_ETC/conf
ENV ODOO_DATA=/var/lib/Odoo
ENV ODOO_ADDONS=/mnt/extra-addons

# Crear usuario odoo (dejamos que el sistema asigne UID/GID)
RUN useradd -m -s /bin/bash odoo

# Dependencias básicas y libssl1.1 (para wkhtml en 24.04)
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        wget \
        software-properties-common \
    && wget http://security.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_amd64.deb \
    && dpkg -i libssl1.1_1.1.0g-2ubuntu4_amd64.deb

# Python base y venv
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        python3 \
        python3-venv \
        python3-dev \
        python3-pip

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:${PATH}"
RUN /opt/venv/bin/pip install --upgrade pip

# Paquetes del sistema necesarios para Odoo
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        vim \
        git \
        curl \
        postgresql-client \
        ca-certificates \
        dirmngr \
        fonts-noto-cjk \
        gnupg \
        libssl-dev \
        node-less \
        npm \
        python3-num2words \
        python3-phonenumbers \
        python3-pyldap \
        python3-qrcode \
        python3-renderpm \
        python3-setuptools \
        python3-slugify \
        python3-vobject \
        python3-watchdog \
        python3-xlrd \
        python3-xlwt \
        xz-utils \
        libjpeg8-dev \
        zlib1g-dev \
        libpq-dev \
        libsasl2-dev \
        libldap2-dev \
        build-essential \
        libxslt-dev \
        libzip-dev \
        libffi-dev \
        cargo \
        openssh-server \
        fail2ban \
        libxml2-dev \
        libxslt1-dev \
        libmysqlclient-dev \
        libjpeg-dev \
        liblcms2-dev \
        libblas-dev \
        libatlas-base-dev \
        openjdk-11-jdk \
        gettext \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Último cliente de PostgreSQL 16
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt noble-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql-client-16

# Librerías Python adicionales (en el venv)
RUN /opt/venv/bin/pip install \
        num2words \
        phonenumbers \
        psycopg2-binary \
        watchdog \
        xlwt \
        psutil \
        cryptography \
        pandas \
        json2html \
        netaddr \
        rsa==4.9 \
        pycryptodome \
        pypeg2 \
        cachetools

# Clonar Odoo (último commit de 19.0)
RUN git clone https://github.com/odoo/odoo.git --depth=1 --branch ${ODOO_VERSION} --single-branch ${ODOO_HOME}
RUN ln -s /odoo/odoo-bin /usr/bin/odoo

# Crear directorios base y asignar a odoo
RUN mkdir -p ${ODOO_ETC} ${ODOO_CONF_DIR} ${ODOO_DATA} ${ODOO_ADDONS} \
    && chown -R odoo:odoo ${ODOO_ETC} ${ODOO_DATA} ${ODOO_ADDONS} ${ODOO_HOME} \
    && chmod -R 775 ${ODOO_DATA}

# Copiar template y scripts
COPY odoo.template ${ODOO_ETC}/odoo.template
COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/wait-for-psql.py /usr/local/bin/entrypoint.sh

# Instalar dependencias de Odoo en el venv
WORKDIR ${ODOO_HOME}
RUN /opt/venv/bin/pip install -r requirements.txt

# (Opcional) Declarar volumen de datos para que nuevos volúmenes hereden la estructura
VOLUME ${ODOO_DATA}

# Ejecutar como usuario no-root
USER odoo
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
