FROM php:7.1-fpm-alpine
MAINTAINER Jeffrey Boehm "jeff@ressourcenkonflikt.de"

ENV SELF_URL_PATH=http://localhost \
    DB_HOST=mysql \
    DB_PORT=3306 \
    DB_NAME=ttrss \
    DB_USER=ttrss \
    DB_PASS=ttrss \
    TTRSS_URL=https://tt-rss.org/gitlab/fox/tt-rss/repository/archive.tar.gz?ref=master \
    FEVER_URL=https://github.com/dasmurphy/tinytinyrss-fever-plugin/archive/master.tar.gz \
    FEEDLY_URL=https://github.com/levito/tt-rss-feedly-theme/archive/master.tar.gz

RUN apk --no-cache add \
      nginx \
      supervisor \
      wget \
      ca-certificates \
      libmcrypt-dev \
      libpng-dev && \
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
    wget -q -O- $FEVER_URL | tar -xzC plugins/ --strip-components 2 --one-top-level=fever && \
    wget -q -O- $FEEDLY_URL | tar -xzC /tmp --strip-components 1 && \
      mv /tmp/feedly.css /tmp/feedly themes/ && \
      sed -e "s/1.15.3/16.8/g" -i themes/feedly.css && \
    rm -rf /tmp/* && \
    ln -sf /tmp/config.php config.php && \
    rm -rf /var/lib/nginx/tmp /var/www/html/lock && \
    ln -sf /tmp /var/lib/nginx/tmp && \
    ln -sf /tmp /var/www/html/lock
COPY rootfs/ /

EXPOSE 80
VOLUME ["/var/www/html/feed-icons", "/var/www/html/cache"]

CMD ["/usr/local/bin/entrypoint.sh"]
