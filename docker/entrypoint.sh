#!/bin/bash

APP_KEY=${APP_KEY:-SECRET}
DB_HOST=${DB_HOST:-mysql}
DB_PASSWORD=${DB_PASSWORD:-cachet}
MAIL_HOST=${MAIL_HOST:-mailtrap.io}
MAIL_USERNAME=${MAIL_USERNAME:-null}
MAIL_PASSWORD=${MAIL_PASSWORD:-null}
MAIL_ADDRESS=${MAIL_ADDRESS:-null}

sed 's,{{APP_KEY}},'"${APP_KEY}"',g' -i /var/www/html/.env
sed 's,{{DB_HOST}},'"${DB_HOST}"',g' -i /var/www/html/.env
sed 's,{{DB_PASSWORD}},'"${DB_PASSWORD}"',g' -i /var/www/html/.env
sed 's,{{MAIL_HOST}},'"${MAIL_HOST}"',g' -i /var/www/html/.env
sed 's,{{MAIL_USERNAME}},'"${MAIL_USERNAME}"',g' -i /var/www/html/.env
sed 's,{{MAIL_PASSWORD}},'"${MAIL_PASSWORD}"',g' -i /var/www/html/.env
sed 's,{{MAIL_ADDRESS}},'"${MAIL_ADDRESS}"',g' -i /var/www/html/.env

php artisan down
php composer.phar install --no-dev -o --no-scripts
php artisan app:update
php artisan up

echo "Starting supervisord..."
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf

exit 0
