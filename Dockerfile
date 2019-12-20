FROM php:7.4-fpm
LABEL maintainer="Paapa Abdullah Morgan <paapaabdullahm@gmail.com>"

# Install persistent build dependencies
RUN set -eux; \
	apt update; \
	apt install -y --no-install-recommends \
    aspell-en \
    curl \
    file \
    ghostscript \
    libc6 \
    libcurl4 \
    libgmp10 \
    libsqlite3-0 \
    mariadb-client \
    pkg-config \
    re2c \
    ucf \
    unzip \
    wget \
    zip \
	; \
	rm -rf /var/lib/apt/lists/*

# Install ephemeral build dependencies
RUN set -ex; \
	savedAptMark="$(apt-mark showmanual)"; \
	apt update; \
	apt install -y --no-install-recommends \
	libc-client-dev \
    libcurl4-openssl-dev \
    libfreetype6-dev \
    libgmp-dev \
    libicu-dev \
    libjpeg-dev \
    libkrb5-dev \
    libldap2-dev \
    libldb-dev \
    libmagickwand-dev \
    libmcrypt-dev \
    libmhash-dev \
    libonig-dev \
    libpng-dev \
    libpq-dev \
    libpspell-dev \
    libsqlite3-dev \
    libssl-dev \
    libtidy-dev \
    libwebp-dev \
    libxml2-dev \
    libxpm-dev \
    libxslt-dev \
    libzip-dev \
	; \
	#
    # Configure php extensions
	docker-php-ext-configure gd --with-freetype --with-jpeg; \
	#
    # Install php extensions
	docker-php-ext-install -j "$(nproc)" \
    bcmath \
    exif \
    gd \
    mysqli \
    opcache \
    zip \
	; \
	#
    # Install php extensions via pecl
	pecl install imagick-3.4.4; \
	#
	# Enable installed php extensions
	docker-php-ext-enable imagick; \
    #
    # Reset apt-mark
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { print $3 }' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	#
    # Remove all build dependencies
	apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*;

# Set recommended opcache php.ini settings
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Configure-error-logging
RUN { \
    echo 'error_reporting = E_ERROR | E_WARNING | E_PARSE | E_CORE_ERROR | E_CORE_WARNING | E_COMPILE_ERROR | E_COMPILE_WARNING | E_RECOVERABLE_ERROR'; \
    echo 'display_errors = Off'; \
    echo 'display_startup_errors = Off'; \
    echo 'log_errors = On'; \
    echo 'error_log = /dev/stderr'; \
    echo 'log_errors_max_len = 1024'; \
    echo 'ignore_repeated_errors = On'; \
    echo 'ignore_repeated_source = Off'; \
    echo 'html_errors = Off'; \
} > /usr/local/etc/php/conf.d/error-logging.ini

# Set usermod
RUN usermod -u 1000 www-data;

VOLUME /var/www/html
EXPOSE 9000
CMD ["php-fpm"]
