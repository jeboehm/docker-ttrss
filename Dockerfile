FROM php:7.1-fpm-alpine
MAINTAINER Jeffrey Boehm "jeff@ressourcenkonflikt.de"

ENV SELF_URL_PATH=http://localhost \
    DB_HOST=mysql \
    DB_PORT=3306 \
    DB_NAME=ttrss \
    DB_USER=ttrss \
    DB_PASS=ttrss \
    TTRSS_URL=https://tt-rss.org/gitlab/fox/tt-rss/repository/archive.tar.gz?ref=master \
    FEVER_URL=https://github.com/dasmurphy/tinytinyrss-fever-plugin/archive/1.4.7.tar.gz

RUN apk --no-cache add \
      nginx \
      supervisor \
      wget \
      ca-certificates \
      libmcrypt-dev \
      libpng-dev vim && \
    docker-php-ext-install -j4 \
      mcrypt \
      gd \
      mysqli \
      pdo_mysql && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    ln -s /usr/local/bin/php /usr/bin/php && \
    update-ca-certificates

RUN wget -q -O- $TTRSS_URL | tar -xzC . --strip-components 1 && \
    wget -q -O- $FEVER_URL | tar -xzC plugins.local/ --strip-components 2 --one-top-level=fever && \
    ln -sf /tmp/config.php config.php
COPY rootfs/ /

EXPOSE 80
VOLUME ["/var/www/html/feed-icons", "/var/www/html/cache"]

CMD ["/usr/local/bin/entrypoint.sh"]
