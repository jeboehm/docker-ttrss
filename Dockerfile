ARG PHP_VER=7.2
FROM jeboehm/php-nginx-base:${PHP_VER}
LABEL maintainer="jeff@ressourcenkonflikt.de"

ARG TTRSS_URL=https://git.tt-rss.org/git/tt-rss/archive/master.tar.gz
ARG FEVER_URL=https://github.com/DigitalDJ/tinytinyrss-fever-plugin/archive/master.tar.gz
ARG FEEDLY_URL=https://github.com/levito/tt-rss-feedly-theme/archive/master.tar.gz

ENV SELF_URL_PATH=http://localhost \
    DB_HOST=mysql \
    DB_PORT=3306 \
    DB_NAME=ttrss \
    DB_USER=ttrss \
    DB_PASS=ttrss
RUN wget -q -O- ${TTRSS_URL} | tar -xzC . --strip-components 1 && \
    wget -q -O- ${FEVER_URL} | tar -xzC plugins/ --strip-components 1 --one-top-level=fever && \
    wget -q -O- ${FEEDLY_URL} | tar -xzC /tmp --strip-components 1 && \
      mv /tmp/feedly.css /tmp/feedly themes/ && \
    rm -rf /tmp/* && \
    ln -sf /tmp/config.php config.php

COPY rootfs/ /

VOLUME ["/var/www/html/feed-icons"]

CMD ["/usr/local/bin/entrypoint.sh"]
