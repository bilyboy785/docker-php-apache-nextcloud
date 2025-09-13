ARG PHP_TAG=8.4
FROM php:${PHP_TAG}-apache

ARG PUID=1000
ARG PGID=1000

ENV TZ=Europe/Paris

RUN groupmod -o -g ${PGID} www-data \
    && usermod -o -u ${PUID} -g www-data www-data

RUN apt-get update && apt-get install -y \
    libpng-dev \
    imagemagick \
    libmagickwand-dev \
    ghostscript \
    ffmpeg \
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
  --with-webp \
  --with-freetype

RUN pecl install redis && docker-php-ext-enable redis \
    && pecl install memcached && docker-php-ext-enable memcached \
    && pecl install apcu && docker-php-ext-enable apcu

RUN docker-php-ext-install -j$(nproc) \
  gd \
  sysvsem \
  exif \
  bz2 \
  zip \
  intl \
  bcmath \
  gmp \
  pcntl \
  pdo_mysql \
  && pecl install imagick \
  && docker-php-ext-enable imagick opcache \
  && a2enmod rewrite headers env dir mime setenvif

RUN apt-get purge -y --auto-remove libfreetype6-dev libjpeg62-turbo-dev libpng-dev && \
   rm -rf /var/lib/apt/lists/*

RUN a2enmod remoteip headers

COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY remoteip.conf /etc/apache2/conf-available/remoteip.conf

WORKDIR /var/www/html

EXPOSE 80

CMD ["apache2-foreground"]

