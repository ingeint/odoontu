FROM ubuntu:20.04

ENV ODOO_VERSION=13.0
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
                wkhtmltopdf \
                libffi-dev \
                cargo \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install num2words phonenumbers psycopg2-binary watchdog xlwt psutil cryptography xades pyopenssl xmlsig suds-jurko

RUN git clone https://github.com/odoo/odoo.git --depth=1 --branch $ODOO_VERSION --single-branch /odoo

RUN ln -s /odoo/odoo-bin /usr/bin/odoo

WORKDIR /odoo

RUN pip3 install -r requirements.txt

CMD ["odoo", "-c", "/etc/odoo/odoo.conf"]
