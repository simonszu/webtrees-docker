#! /bin/bash

if [ ! -f /var/www/html/data/index.php ]; then
  cp /tmp/index.php /var/www/html/data/index.php
  cp /tmp/.htaccess /var/www/html/data/.htaccess
fi

chown -R www-data:root /var/www/html/data

/usr/local/bin/apache2-foreground
