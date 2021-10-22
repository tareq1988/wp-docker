FROM php:7.4-fpm-alpine

# persistent dependencies
RUN apk add --no-cache \
    # in theory, docker-entrypoint.sh is POSIX-compliant, but priority is a working, consistent image
    bash \
    # BusyBox sed is not sufficient for some of our sed expressions
    sed \
    # Ghostscript is required for rendering PDF previews
    ghostscript \
    # install mysql
    mysql-client \
    # Alpine package for "imagemagick" contains ~120 .so files, see: https://github.com/docker-library/wordpress/pull/497
    imagemagick

# Set pager for WP-CLI
ENV PAGER=less

# install the PHP extensions we need (https://make.wordpress.org/hosting/handbook/handbook/server-environment/#php-extensions)
RUN set -ex; \
    \
    apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    freetype-dev \
    imagemagick-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libzip-dev \
    ; \
    \
    docker-php-ext-configure gd --with-freetype --with-jpeg; \
    docker-php-ext-install -j "$(nproc)" \
    bcmath \
    exif \
    gd \
    mysqli \
    zip \
    ; \
    pecl install imagick-3.4.4; \
    pecl install redis; \
    docker-php-ext-enable imagick redis; \
    \
    runDeps="$( \
    scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
    | tr ',' '\n' \
    | sort -u \
    | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --virtual .wordpress-phpexts-rundeps $runDeps; \
    apk del .build-deps; \
    # Donwload and install composer
    curl -sSL "https://getcomposer.org/installer" | php \
    && mv composer.phar /usr/local/bin/composer; \
    # Install wp-cli
    curl -O "https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar" \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && echo 'wp() { /usr/local/bin/wp "$@" --allow-root; }' >> ~/.bashrc