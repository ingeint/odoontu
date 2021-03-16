FROM ubuntu:20.04

ENV ODOO_VERSION=14.0
ENV ODOO_CONF=/etc/odoo/odoo.conf

COPY odoo.conf $ODOO_CONF

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
                openssh-server fail2ban \
                python3-dev \
                libxml2-dev \
                libxslt1-dev \
                zlib1g-dev \
                libsasl2-dev \
                libldap2-dev \
                build-essential \
                libssl-dev \
                libffi-dev \
                libmysqlclient-dev \
                libjpeg-dev \
                libpq-dev \
                libjpeg8-dev \
                liblcms2-dev \
                libblas-dev \
                libatlas-base-dev \                
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

RUN pip3 install num2words phonenumbers psycopg2-binary watchdog xlwt psutil cryptography xades pyopenssl xmlsig suds-jurko pandas

RUN git clone https://github.com/odoo/odoo.git --depth=1 --branch $ODOO_VERSION --single-branch /odoo

RUN ln -s /odoo/odoo-bin /usr/bin/odoo

WORKDIR /odoo

RUN pip3 install -r requirements.txt

CMD ["odoo", "-c", "/etc/odoo/odoo.conf"]
