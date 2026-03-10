FROM ubuntu:24.04

ENV ODOO_VERSION=19.0
ENV ODOO_HOME=/odoo
ENV ODOO_ETC=/home/odoo/etc
ENV ODOO_CONF_DIR=/home/odoo/etc/conf
ENV ODOO_DATA=/var/lib/odoo
ENV ODOO_ADDONS=/mnt/extra-addons

# Crear usuario odoo
RUN useradd -m -s /bin/bash odoo

# Dependencias base
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        wget \
        software-properties-common \
        curl \
        git \
        vim \
        ca-certificates \
        gnupg \
        dirmngr \
        fonts-noto-cjk \
        build-essential \
        xz-utils \
        gosu \
    && rm -rf /var/lib/apt/lists/*

# Python base y venv
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        python3 \
        python3-venv \
        python3-dev \
        python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:${PATH}"
RUN /opt/venv/bin/pip install --upgrade pip

# Repositorio oficial PostgreSQL para cliente 16
RUN echo "deb http://apt.postgresql.org/pub/repos/apt noble-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg

# Paquetes del sistema necesarios para Odoo
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        postgresql-client \
        postgresql-client-16 \
        ca-certificates \
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
        libxslt-dev \
        libzip-dev \
        libffi-dev \
        cargo \
        openssh-server \
        fail2ban \
        libxml2-dev \
        libxslt1-dev \
        default-libmysqlclient-dev \
        libjpeg-dev \
        liblcms2-dev \
        libblas-dev \
        libatlas-base-dev \
        openjdk-11-jdk \
        gettext \
        xfonts-75dpi \
        xfonts-base \
        fontconfig \
    && rm -rf /var/lib/apt/lists/*

# wkhtmltopdf compatible con Ubuntu 24.04 usando build jammy
RUN wget -q https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_amd64.deb \
    && apt-get update \
    && apt-get install -y --no-install-recommends ./wkhtmltox_0.12.6.1-2.jammy_amd64.deb \
    && rm -f wkhtmltox_0.12.6.1-2.jammy_amd64.deb \
    && rm -rf /var/lib/apt/lists/*

# Librerías Python adicionales en el venv
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
        cachetools \
        qifparse

# Clonar Odoo
RUN git clone https://github.com/odoo/odoo.git --depth=1 --branch ${ODOO_VERSION} --single-branch ${ODOO_HOME}
RUN ln -s /odoo/odoo-bin /usr/bin/odoo

# Crear directorios base y asignar a odoo
RUN mkdir -p ${ODOO_ETC} ${ODOO_CONF_DIR} ${ODOO_DATA} ${ODOO_ADDONS} \
    && chown -R odoo:odoo ${ODOO_ETC} ${ODOO_DATA} ${ODOO_ADDONS} ${ODOO_HOME} \
    && chmod -R 775 ${ODOO_DATA}

RUN mkdir -p /home/odoo/.local/share \
    && chown -R odoo:odoo /home/odoo/.local \
    && ln -s ${ODOO_DATA} /home/odoo/.local/share/Odoo

# Copiar template y scripts
COPY odoo.template ${ODOO_ETC}/odoo.template
COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/wait-for-psql.py /usr/local/bin/entrypoint.sh \
    && chown -R odoo:odoo ${ODOO_ETC}

# Instalar dependencias de Odoo en el venv
WORKDIR ${ODOO_HOME}
RUN /opt/venv/bin/pip install -r requirements.txt

# Logs
RUN mkdir -p /var/log/odoo && chown -R odoo:odoo /var/log/odoo

# Declarar volumen de datos
VOLUME ${ODOO_DATA}

# Ejecutar como usuario no-root
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
