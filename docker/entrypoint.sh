#!/bin/sh
set -eu

mkdir -p \
    storage/app/public \
    storage/app/uploads \
    storage/app/temp \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views \
    bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache

# A bind-mounted source tree has no compiled JS; copy in the bundles built into the image
if [ ! -f public/js/install.min.js ]; then
    mkdir -p public/js
    cp -R /opt/akaunting/public/js/. public/js/
fi

if [ -f .env ] && grep -q '^APP_KEY=$' .env; then
    php artisan key:generate --force --no-interaction
fi

exec "$@"
