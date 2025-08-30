FROM php:8.3-apache

ARG PUID=1000
ARG PGID=10

RUN groupmod -o -g ${PGID} www-data \
    && usermod -o -u ${PUID} -g www-data www-data

RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libwebp-dev \
    libxml2-dev \
    libzip-dev \
    libicu-dev \
    libgmp-dev \
    libmemcached-dev \
    libmagickwand-dev \
    unzip \
    git \
    bzip2

RUN docker-php-ext-configure gd \
  --with-jpeg \
  --with-webp

# Installer les extensions PHP via PECL et activer les extensions
RUN pecl install redis && docker-php-ext-enable redis \
    && pecl install memcached && docker-php-ext-enable memcached \
    && pecl install apcu && docker-php-ext-enable apcu

RUN docker-php-ext-install -j$(nproc) \
  gd \
  exif \
  bz2 \
  zip \
  intl \
  bcmath \
  gmp \
  pdo_mysql \
  && pecl install imagick \
  && docker-php-ext-enable imagick opcache \
  && a2enmod rewrite headers env dir mime setenvif

COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini

WORKDIR /var/www/html

EXPOSE 80

CMD ["apache2-foreground"]

