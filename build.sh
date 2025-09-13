#!/bin/bash

read -p "PHP Version : " php_ver

docker buildx build --platform linux/amd64,linux/arm64 \
  -t martinbouillaud/php-apache-nextcloud:php-${php_ver} .