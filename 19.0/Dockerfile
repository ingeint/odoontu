FROM ubuntu:24.04

ENV ODOO_VERSION=19.0
ENV ODOO_ETC=/etc/odoo
ENV ODOO_CONF=$ODOO_ETC/conf
ENV ODOO_DATA=$ODOO_ETC/data
ENV ODOO_HOME=/odoo

# Actualizar repositorios e instalar dependencias básicas
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		wget software-properties-common \ 
		&& wget http://security.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_amd64.deb \
		&& dpkg -i libssl1.1_1.1.0g-2ubuntu4_amd64.deb 

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y python3 python3-venv python3-dev python3-pip
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN /opt/venv/bin/pip install --upgrade pip
	
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
                python3-pip \
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
                python3-dev \
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

# install latest postgresql-client
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt noble-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt update && apt install postgresql-client-16 -y
RUN python3 --version
RUN pip3 install num2words phonenumbers psycopg2-binary watchdog xlwt psutil cryptography pandas json2html netaddr rsa==4.9 pycryptodome pypeg2 cachetools
RUN git clone https://github.com/odoo/odoo.git --depth=1 --branch $ODOO_VERSION --single-branch $ODOO_HOME
RUN ln -s /odoo/odoo-bin /usr/bin/odoo

# Crear usuario y directorios necesarios
RUN useradd -Ms /bin/bash odoo
RUN mkdir -p $ODOO_ETC $ODOO_DATA $ODOO_CONF

# Copiar los scripts y configuraciones
COPY odoo.template $ODOO_ETC/odoo.template
COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Configurar permisos
RUN chmod +x /usr/local/bin/wait-for-psql.py /usr/local/bin/entrypoint.sh
RUN chown -R odoo:odoo $ODOO_ETC $ODOO_HOME $ODOO_DATA

# Instalar dependencias de Odoo
WORKDIR $ODOO_HOME
RUN pip3 install -r requirements.txt

RUN mkdir -p /var/lib/odoo/filestore && chown -R odoo:odoo /var/lib/odoo && chmod -R 775 /var/lib/odoo

RUN mkdir -p /mnt/extra-addons && chown -R odoo:odoo /mnt/extra-addons && chmod -R 775 /mnt/extra-addons

# Configurar el entrypoint
USER odoo
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

