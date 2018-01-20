ARG PHP_VER=7.1
FROM jeboehm/php-nginx-base:${PHP_VER}
LABEL maintainer="jeff@ressourcenkonflikt.de"

ENV SELF_URL_PATH=http://localhost \
    DB_HOST=mysql \
    DB_PORT=3306 \
    DB_NAME=ttrss \
    DB_USER=ttrss \
    DB_PASS=ttrss \
    TTRSS_URL=https://git.tt-rss.org/git/tt-rss/archive/master.tar.gz \
    FEVER_URL=https://github.com/jeboehm/tinytinyrss-fever-plugin/archive/master.tar.gz \
    FEEDLY_URL=https://github.com/levito/tt-rss-feedly-theme/archive/master.tar.gz

RUN wget -q -O- $TTRSS_URL | tar -xzC . --strip-components 1 && \
    wget -q -O- $FEVER_URL | tar -xzC plugins/ --strip-components 2 --one-top-level=fever && \
    wget -q -O- $FEEDLY_URL | tar -xzC /tmp --strip-components 1 && \
      mv /tmp/feedly.css /tmp/feedly themes/ && \
    rm -rf /tmp/* /var/www/html/lock && \
    ln -sf /tmp/config.php config.php && \
    ln -sf /tmp /var/www/html/lock
COPY rootfs/ /

VOLUME ["/var/www/html/feed-icons", "/var/www/html/cache"]

CMD ["/usr/local/bin/entrypoint.sh"]
