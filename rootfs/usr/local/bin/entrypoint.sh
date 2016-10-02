#!/bin/sh

chmod 777 -R /var/www/html/cache /var/www/html/feed-icons /var/www/html/lock

/usr/local/bin/init.php
/usr/bin/supervisord -c /etc/supervisord.conf
