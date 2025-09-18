# image php+fpm
FROM php:8.3-fpm-alpine

#utilities and dev packages
RUN apk add --no-cache \
    bash git curl unzip icu-libs oniguruma libxml2 libzip \
    libpng libjpeg-turbo libwebp freetype \
    && apk add --no-cache --virtual .build-deps \
    build-base icu-dev oniguruma-dev libxml2-dev libzip-dev zlib-dev \
    libpng-dev libjpeg-turbo-dev libwebp-dev freetype-dev

#build and enabling extensions:
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
 && docker-php-ext-install -j"$(nproc)" \
    pdo_mysql mbstring exif pcntl bcmath gd intl zip \
 && apk del --no-network .build-deps

#compose install
RUN curl -sS https://getcomposer.org/installer | php \
 && mv composer.phar /usr/local/bin/composer

WORKDIR /var/www/html
