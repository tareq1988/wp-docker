FROM php:7.1-fpm

RUN docker-php-ext-install mysqli \
    && pecl install redis && docker-php-ext-enable redis

COPY conf/php/php.ini /usr/local/etc/php/conf.d/40-custom.ini