FROM php:8.3-fpm

WORKDIR /var/www

RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libonig-dev libxml2-dev \
    nodejs npm

RUN docker-php-ext-install pdo pdo_mysql mbstring

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# DO NOT run composer install here when using volumes

CMD ["php-fpm"]