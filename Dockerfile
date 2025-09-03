# FROM ubuntu:22.04

# # Set default build arguments
# ARG NODE_VERSION=18
# ARG POSTGRES_VERSION=14
# ARG DEBIAN_FRONTEND=noninteractive

# # Install base dependencies
# RUN apt-get update && apt-get install -y \
#     gnupg gosu curl ca-certificates zip unzip git supervisor sqlite3 libcap2-bin libpng-dev python2 software-properties-common \
#     && rm -rf /var/lib/apt/lists/*

# # Add Ondřej Surý PHP PPA (for PHP 8.1)
# RUN curl -fsSL https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x14aa40ec0831756756d7f66c4f4ea0aae5267a6c \
#     | gpg --dearmor -o /usr/share/keyrings/ppa_ondrej_php.gpg \
#     && echo "deb [signed-by=/usr/share/keyrings/ppa_ondrej_php.gpg] https://ppa.launchpadcontent.net/ondrej/php/ubuntu jammy main" \
#     > /etc/apt/sources.list.d/ppa_ondrej_php.list

# # Install PHP 8.1 + extensions
# RUN apt-get update && apt-get install -y \
#     php8.1-cli php8.1-dev \
#     php8.1-pgsql php8.1-sqlite3 php8.1-gd \
#     php8.1-curl php8.1-imap php8.1-mysql php8.1-mbstring \
#     php8.1-xml php8.1-zip php8.1-bcmath php8.1-soap \
#     php8.1-intl php8.1-readline php8.1-ldap \
#     php8.1-msgpack php8.1-igbinary php8.1-redis php8.1-swoole \
#     php8.1-memcached php8.1-pcov php8.1-xdebug \
#     && rm -rf /var/lib/apt/lists/*

# # Install Composer
# RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

# # Install Node.js & npm
# RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
#     && apt-get install -y nodejs \
#     && npm install -g npm \
#     && rm -rf /var/lib/apt/lists/*

# # Install Yarn
# RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg \
#     | gpg --dearmor -o /usr/share/keyrings/yarn.gpg \
#     && echo "deb [signed-by=/usr/share/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main" \
#     > /etc/apt/sources.list.d/yarn.list \
#     && apt-get update && apt-get install -y yarn \
#     && rm -rf /var/lib/apt/lists/*

# # Install PostgreSQL client
# RUN curl -sS https://www.postgresql.org/media/keys/ACCC4CF8.asc \
#     | gpg --dearmor -o /usr/share/keyrings/pgdg.gpg \
#     && echo "deb [signed-by=/usr/share/keyrings/pgdg.gpg] http://apt.postgresql.org/pub/repos/apt jammy-pgdg main" \
#     > /etc/apt/sources.list.d/pgdg.list \
#     && apt-get update && apt-get install -y postgresql-client-${POSTGRES_VERSION} mysql-client \
#     && rm -rf /var/lib/apt/lists/*

# # Set working directory
# WORKDIR /var/www

# # Copy project files
# COPY . .

# # Install PHP dependencies
# RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# # Install Node dependencies
# RUN yarn install --frozen-lockfile && yarn run build

# # Expose Laravel port
# EXPOSE 8000

# # Start Laravel
# CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]



# FROM php:8.1.27-cli-slim

# # Upgrade system packages to reduce vulnerabilities
# RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

# # Set build arguments
# ARG NODE_VERSION=18
# ARG POSTGRES_VERSION=14
# ARG DEBIAN_FRONTEND=noninteractive

# # Install system dependencies
# RUN apt-get update && apt-get install -y \
#     git unzip libpng-dev libpq-dev libzip-dev libicu-dev libxml2-dev \
#     libonig-dev libldap2-dev libssl-dev \
#     curl zip sqlite3 supervisor \
#     && docker-php-ext-install \
#        pdo pdo_mysql pdo_pgsql gd bcmath intl pcntl soap xml zip opcache \
#     && rm -rf /var/lib/apt/lists/*

# # Install Composer
# COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# # Install Node.js and npm
# RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
#     && apt-get install -y nodejs \
#     && npm install -g npm \
#     && rm -rf /var/lib/apt/lists/*

# # Install Yarn
# RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg \
#     | gpg --dearmor -o /usr/share/keyrings/yarn.gpg \
#     && echo "deb [signed-by=/usr/share/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main" \
#     > /etc/apt/sources.list.d/yarn.list \
#     && apt-get update && apt-get install -y yarn \
#     && rm -rf /var/lib/apt/lists/*

# # Install PostgreSQL & MySQL clients
# RUN apt-get update && apt-get install -y \
#     postgresql-client-${POSTGRES_VERSION} mysql-client \
#     && rm -rf /var/lib/apt/lists/*

# # Set working directory
# WORKDIR /var/www

# # Copy project files
# COPY . .

# # Install PHP dependencies
# RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# # Install Node dependencies and build assets
# RUN yarn install --frozen-lockfile && yarn run build

# # Expose Laravel port
# EXPOSE 8000

# # Start Laravel development server
# CMD ["php", "php-fpm"], "artisan", "serve", "--host=0.0.0.0", "--port=8000"]



# sudo docker build -t laravel-realworld .
# sudo docker run -p 8000:8000 laravel-realworld

# # ---- Stage 1: Build Laravel dependencies ----
# FROM composer:2 AS vendor

# WORKDIR /app

# # Copy composer files first (better caching)
# COPY composer.json composer.lock ./

# # Install PHP dependencies without dev packages
# RUN composer install --no-dev --no-scripts --no-progress --prefer-dist

# # Copy rest of Laravel app
# COPY . .

# # Run Laravel scripts (optimize config, routes, views)
# RUN composer dump-autoload --optimize && \
#     php artisan config:clear && \
#     php artisan route:clear && \
#     php artisan view:clear

# # ---- Stage 2: PHP-FPM runtime ----
# FROM php:8.2-fpm-alpine

# # Install PHP extensions for Laravel + PostgreSQL
# RUN apk add --no-cache \
#         libpq-dev \
#         oniguruma-dev \
#         zip \
#         unzip \
#         git \
#         bash && \
#     docker-php-ext-install pdo pdo_pgsql mbstring exif pcntl bcmath

# WORKDIR /var/www/html

# # Copy app from build stage
# COPY --from=vendor /app ./

# # Set permissions for Laravel storage
# RUN chown -R www-data:www-data storage bootstrap/cache

# # Expose PHP-FPM port
# EXPOSE 8000

# CMD ["php-fpm"]



# # Stage 1: Build dependencies
# FROM php:8.2-fpm AS build

# # Install system dependencies & PHP extensions
# RUN apt-get update && apt-get install -y \
#     git \
#     unzip \
#     libpq-dev \
#     libzip-dev \
#     zip \
#     curl \
#     && docker-php-ext-install pdo pdo_pgsql zip

# # Install Composer
# COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# # Set working directory
# WORKDIR /var/www/html

# # Copy only composer files first (for better caching)
# COPY composer.json composer.lock ./

# # Install PHP dependencies (no dev dependencies in production)
# ARG APP_ENV=production
# RUN if [ "$APP_ENV" = "production" ]; then \
#       composer install --no-dev --optimize-autoloader; \
#     else \
#       composer install; \
#     fi

# # Copy application code
# COPY . .

# # Ensure Laravel storage & bootstrap cache dirs are writable
# RUN chown -R www-data:www-data storage bootstrap/cache

# # Stage 2: Production image
# FROM php:8.2-fpm

# # Install system dependencies & PHP extensions again
# RUN apt-get update && apt-get install -y \
#     libpq-dev \
#     libzip-dev \
#     zip \
#     && docker-php-ext-install pdo pdo_pgsql zip

# # Set working directory
# WORKDIR /var/www/html

# # Copy app from build stage
# COPY --from=build /var/www/html /var/www/html

# # Set ownership for Laravel
# RUN chown -R www-data:www-data /var/www/html

# # Expose FPM port
# EXPOSE 9000

# # Run php-fpm
# CMD ["php-fpm"]






# FROM php:8.2-fpm

# # Install system dependencies
# RUN apt-get update && apt-get install -y \
#     libpq-dev \
#     unzip \
#     git \
#     nginx

# # Install PHP extensions
# RUN docker-php-ext-install pdo pdo_pgsql

# # Copy Laravel app
# COPY . /var/www/html

# # Configure Nginx
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# # Run Nginx + PHP-FPM
# CMD service nginx start && php-fpm





FROM php:8.2-fpm

WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpq-dev \
    libzip-dev \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libicu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd zip bcmath \
    && docker-php-ext-install intl

# Install PHP extensions for Laravel + PostgreSQL + Redis
RUN docker-php-ext-install pdo pdo_pgsql pgsql
RUN pecl install redis \
    && docker-php-ext-enable redis

# RUN apt-get update && apt-get install -y \
#     libicu-dev \
#     && docker-php-ext-install intl


# Install Composer globally
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy Laravel source
COPY . .

# Set permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

RUN echo "date.timezone=UTC" > /usr/local/etc/php/conf.d/timezone.ini


EXPOSE 9000

# CMD ["php-fpm"]

# CMD ["php-fpm", "-F", "-R"]
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=9000"]
