#!bin/bash

if [ -f "/var/www/html/galambey.42.fr/wp-config-sample.php" ]; then
rm -rf /var/www/html/galambey.42.fr/wp-config-sample.php
wp core install --allow-root --path=${WP_SITEPATH} --url=${WP_SITEURL} --title=${WP_HOME} --admin_user=${WP_ADMIN_USER} --admin_password=${WP_ADMIN_PASSWORD} --admin_email=${WP_ADMIN_MAIL}
fi

exec php-fpm7.4 -F -R