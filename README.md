# Nextcloud docker Image

[![Docker Pulls](https://badgen.net/docker/pulls/martinbouillaud/php-apache-nextcloud?icon=docker&label=pulls)](https://hub.docker.com/r/martinbouillaud/php-apache-nextcloud/) [![Docker Image Size](https://badgen.net/docker/size/martinbouillaud/php-apache-nextcloud?icon=docker&label=image%20size)](https://hub.docker.com/r/martinbouillaud/php-apache-nextcloud/) ![Github last-commit](https://img.shields.io/github/last-commit/bilyboy785/docker-php-apache-nextcloud)

## Available versions

- martinbouillaud/php-apache-nextcloud:php-8.4 : latest PHP 8.4
- martinbouillaud/php-apache-nextcloud:php-8.3 : PHP 8.3
- martinbouillaud/php-apache-nextcloud:php-8.2 : PHP 8.2
- martinbouillaud/php-apache-nextcloud:php-8.0 : PHP 8.0

## Usage

You can run you Nextcloud instance with this full compose example : 

```yaml
services:
  nextcloud:
    container_name: nextcloud
    image: martinbouillaud/php-apache-nextcloud:php-8.4
    restart: always
    labels:
      ofelia.enabled: true
      ofelia.job-exec.nextcloud-cron.schedule: "@every 5m"
      ofelia.job-exec.nextcloud-cron.user: "www-data"
      ofelia.job-exec.nextcloud-cron.workding_dir: "/var/www/html"
      ofelia.job-exec.nextcloud-cron.command: "php -d memory_limit=1024M -f /var/www/html/cron.php"
      ofelia.job-exec.nextcloud-cron.timeout: "15m"
      ofelia.job-exec.nextcloud-cron.max-retries: "2"
    depends_on:
      mariadb:
        condition: service_healthy
      redis:
        condition: service_healthy
    volumes:
      - ./nextcloud/data:/var/www/html
      - ./nextcloud/php.ini:/usr/local/etc/php/conf.d/custom.ini
      - ./nextcloud/opcache.ini:/usr/local/etc/php/conf.d/opcache.ini
    ports:
      - 8080:80

  ofelia:
    container_name: ofelia
    image: mcuadros/ofelia:latest
    restart: always
    command: daemon --docker
    depends_on: [nextcloud]
    environment:
      TZ: Europe/Paris
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro

  mariadb:
    container_name: mariadb
    image: mariadb:11.4
    restart: always
    environment:
      MARIADB_USER: nextcloud
      MARIADB_PASSWORD: REPLACE_IT
      MARIADB_DATABASE: nextcloud
      MARIADB_ROOT_PASSWORD: REPLACE_IT
    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      start_period: 10s
      interval: 10s
      timeout: 5s
      retries: 3
    volumes:
      - ./nextcloud/mariadb:/var/lib/mysql
      - ./nextcloud/dump.sql:/docker-entrypoint-initdb.d/dump.sql ## Use it if you migrate from non-docker nextcloud installation

  redis:
    container_name: redis
    image: redis:latest
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "redis-cli ping | grep PONG"]
      interval: 1s
      timeout: 3s
      retries: 5
```