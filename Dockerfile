# Compile the front-end bundles (public/js is gitignored build output)
FROM node:18-bookworm AS assets

WORKDIR /app

COPY akaunting-master/package.json akaunting-master/package-lock.json ./
RUN npm ci --no-audit --no-fund

COPY akaunting-master/webpack.mix.js akaunting-master/tailwind.config.js \
     akaunting-master/presets.js akaunting-master/safelist.txt ./
COPY akaunting-master/resources ./resources
COPY akaunting-master/public ./public
COPY akaunting-master/modules ./modules
COPY akaunting-master/app ./app
RUN MIX_TERSER_PARALLEL=1 NODE_OPTIONS=--max-old-space-size=1536 npm run production

FROM php:8.2-apache

ENV APACHE_DOCUMENT_ROOT=/var/www/html

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        libfreetype6-dev \
        libicu-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libzip-dev \
        unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" bcmath gd intl mysqli pdo_mysql zip \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY akaunting-master/composer.json akaunting-master/composer.lock ./
RUN composer install \
        --no-dev \
        --no-interaction \
        --no-progress \
        --no-scripts \
        --prefer-dist \
    && composer dump-autoload --no-dev --optimize --no-scripts

COPY akaunting-master/ .
COPY --from=assets /app/public/js ./public/js
# Kept outside the web root so the entrypoint can restore it over a bind mount
COPY --from=assets /app/public/js /opt/akaunting/public/js
COPY docker/entrypoint.sh /usr/local/bin/akaunting-entrypoint
RUN sed -i 's/\r$//' /usr/local/bin/akaunting-entrypoint \
    && chmod +x /usr/local/bin/akaunting-entrypoint \
    && mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views \
        bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache

ENTRYPOINT ["akaunting-entrypoint"]
CMD ["apache2-foreground"]
