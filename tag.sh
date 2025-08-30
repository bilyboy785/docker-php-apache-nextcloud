#!/bin/bash

read -p "PHP Version: " PHP_VERSION

echo "Building Docker image for PHP ${PHP_VERSION}..."

# Supprime le tag local s'il existe
if git rev-parse "php-${PHP_VERSION}" >/dev/null 2>&1; then
	git tag -d "php-${PHP_VERSION}"
fi

# Supprime le tag distant s'il existe
git push --delete origin "php-${PHP_VERSION}" 2>/dev/null || true

# Crée le tag et le pousse
git tag "php-${PHP_VERSION}"
git push origin "php-${PHP_VERSION}"