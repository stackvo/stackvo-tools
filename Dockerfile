###################################################################
# STACKVO TOOLS - RUNTIME INSTALLATION DOCKERFILE
# Minimal base image + runtime tool installation
###################################################################

FROM php:8.2-fpm-alpine

LABEL maintainer="Stackvo Team"
LABEL description="Stackvo Tools Container - Runtime Installation"
LABEL version="1.0.0"

# Install system dependencies
RUN apk add --no-cache \
    nginx \
    supervisor \
    docker-cli \
    docker-cli-compose \
    bash \
    curl \
    git \
    unzip \
    openjdk21-jre

# Install PHP extensions (all possible extensions for tools)
RUN apk add --no-cache \
    postgresql-dev \
    libzip-dev \
    libmemcached-dev \
    autoconf \
    build-base \
    openssl-dev \
    zlib-dev

# Install PHP extensions
RUN docker-php-ext-install \
    mysqli \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    opcache

# Install PECL extensions
RUN pecl install redis mongodb memcached && \
    docker-php-ext-enable redis mongodb memcached

# Cleanup build dependencies
RUN apk del autoconf build-base

# Install Composer (for PhpMongo)
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin \
    --filename=composer

# Configure PHP (suppress warnings for legacy tools)
RUN echo "error_reporting = E_ERROR | E_PARSE" > /usr/local/etc/php/conf.d/error_reporting.ini && \
    echo "display_errors = Off" >> /usr/local/etc/php/conf.d/error_reporting.ini && \
    echo "log_errors = On" >> /usr/local/etc/php/conf.d/error_reporting.ini

# Create directories
RUN mkdir -p /run/nginx /var/www/html /opt/kafbat

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /var/www/html

EXPOSE 80 8080

ENTRYPOINT ["/entrypoint.sh"]
