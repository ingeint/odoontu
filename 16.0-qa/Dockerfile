FROM ubuntu:22.04

ENV ODOO_VERSION=16.0
ENV ODOO_ETC=/etc/odoo
ENV ODOO_CONF=$ODOO_ETC/conf
ENV ODOO_DATA=$ODOO_ETC/data
ENV ODOO_HOME=/odoo

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		wget \ 
		&& wget http://security.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_amd64.deb \
		&& dpkg -i libssl1.1_1.1.0g-2ubuntu4_amd64.deb
		
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
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

RUN pip3 install num2words phonenumbers psycopg2-binary watchdog xlwt psutil cryptography pandas json2html netaddr rsa==4.9 pycryptodome==3.18.0 pypeg2 
RUN git clone https://github.com/odoo/odoo.git --depth=1 --branch $ODOO_VERSION --single-branch $ODOO_HOME
RUN ln -s /odoo/odoo-bin /usr/bin/odoo
RUN useradd -Ms /bin/bash odoo
RUN mkdir $ODOO_ETC $ODOO_DATA $ODOO_CONF
COPY odoo.conf $ODOO_CONF
RUN chown -R odoo:odoo $ODOO_ETC $ODOO_HOME

WORKDIR $ODOO_HOME
RUN pip3 install -r requirements.txt
COPY addons /mnt/extra-addons/
USER odoo
CMD ["odoo", "-c", "/etc/odoo/conf/odoo.conf"]
