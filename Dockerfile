FROM php:7.1-apache

# Add required PHP extensions
# Notes :
#   - zlib1g-dev & libicu-dev are required by intl extension
#   - libpq-dev is required by pdo_pgsql
RUN requirements="zlib1g-dev libicu-dev libldap2-dev curl git unzip vim net-tools libfreetype6-dev libpq-dev libjpeg62-turbo-dev libmcrypt-dev libpng-dev" \
    && apt-get update \
    && apt-get install libjpeg-dev -y \
    && apt-get install libfreetype6-dev -y \
    && apt-get install -y ${requirements} \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install intl \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install \
    mbstring \
    mcrypt \
    pdo_pgsql \
    && apt-get purge --auto-remove -y


# Apache & PHP configuration
COPY ./docker/php/php.ini /usr/local/etc/php/php.ini

# Override default virtual hosts, so that all requests are served by it,
# no matter the "Host" header sent in the request
COPY ./docker/apache/vhost.conf /etc/apache2/sites-enabled/000-default.conf

# Override security conf to hide apache version
COPY ./docker/apache/security.conf /etc/apache2/conf-available/security.conf

# Override ports conf
COPY ./docker/apache/ports.conf /etc/apache2/ports.conf

# Start rewrite engine
RUN a2enmod rewrite

# Enable headers mod for Access-Control-Allow-Origin
RUN a2enmod headers

# Enable ssl
RUN a2enmod ssl

# Copy files from cloned repository
# NOTE : this implies the repository has been cloned before
# by a CI instance.
COPY ./src /var/www/
WORKDIR /var/www


EXPOSE 80

# Use the PORT environment variable in Apache configuration files.
RUN sed -i 's/80/${PORT}/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf