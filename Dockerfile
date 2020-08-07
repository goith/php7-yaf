FROM php:7.1.32-fpm-alpine3.10

RUN set -ex && docker-php-ext-install  pdo_mysql mysqli opcache \
    && ( apk add \
            --no-cache \
            freetype \
            libpng \
            libjpeg-turbo \
            freetype-dev \
            libpng-dev \
            libjpeg-turbo-dev\
        && docker-php-ext-configure gd \
            --with-gd \
            --with-freetype-dir=/usr/include/ \
            --with-png-dir=/usr/include/ \
            --with-jpeg-dir=/usr/include/ \
        && docker-php-ext-install gd) \
    && ( apk add --no-cache libmcrypt-dev \
        && docker-php-ext-configure mcrypt --with-mcrypt \
        && docker-php-ext-install  mcrypt) 
ENV PHPIZE_DEPS \
        autoconf \
        dpkg-dev dpkg \
        file \
        g++ \
        gcc \
        libc-dev \
        make \
        pkgconf \
        re2c
RUN set -ex \
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        coreutils \
        curl-dev \
        libedit-dev \
        openssl-dev \
        libxml2-dev \
        sqlite-dev \
    && pecl install redis yaf-3.0.5 apcu \
    && echo "extension=redis.so" >> /usr/local/etc/php/conf.d/docker-php-ext-redis.ini  \
    && echo "extension=yaf.so" >> /usr/local/etc/php/conf.d/docker-php-ext-yaf.ini \
    && echo "extension=apcu.so" >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini \
    && pecl update-channels \
    && rm -rf /tmp/pear ~/.pearrc

COPY php.ini /usr/local/etc/php/php.ini

COPY docker.conf /usr/local/etc/php-fpm.d/docker.conf
COPY www.conf /usr/local/etc/php-fpm.d/www.conf
