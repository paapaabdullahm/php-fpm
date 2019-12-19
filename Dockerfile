FROM php:7.4.1-fpm
LABEL maintainer="Abdullah Morgan <paapaabdullahm@gmail.com>"

# Setup build dependencies
RUN set -ex; \
    apt update && apt upgrade -y; \
    apt install -y \
    apt-utils \
    aspell-en \
    curl \
    file \
    firebird-dev \
    libc-client-dev \
    libc6 \
    libcurl4 \
    libcurl4-openssl-dev \
    libfreetype6-dev \
    libgmp-dev \
    libgmp10 \
    libicu-dev \
    libjpeg62-turbo-dev \
    libkrb5-dev \
    libldap2-dev \
    libldb-dev \
    libmagickwand-dev \
    libmcrypt-dev \
    libmhash-dev \
    libpq-dev \
    libpspell-dev \
    librecode-dev \
    librecode0 \
    libsqlite3-0 \
    libsqlite3-dev \
    libssl-dev \
    libtidy-dev \
    libwebp-dev \
    libxml2-dev \
    libxpm-dev \
    libxslt-dev \
    libzip-dev \
    mariadb-client \
    re2c \
    ucf \
    unzip \
    wget \
    zip \
    --no-install-recommends; \
    #
    # Setup libpng via dpkg
    wget http://mirrors.kernel.org/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1_amd64.deb; \
    dpkg -i libpng12-0_1.2.54-1ubuntu1_amd64.deb; apt install -f; \
    rm -f libpng12-0_1.2.54-1ubuntu1_amd64.deb; \
    #
    # Configure php extensions
    docker-php-ext-configure gd \
      --with-freetype-dir=/usr/include/ \
      --with-jpeg-dir=/usr/include/ \
      --with-webp-dir=/usr/include/ \
      --with-png-dir=/usr/include/ \
      --with-xpm-dir=/usr/include/; \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl; \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu; \
    docker-php-ext-configure bcmath --enable-bcmath; \
    docker-php-ext-configure intl --enable-intl; \
    docker-php-ext-configure pcntl --enable-pcntl; \
    docker-php-ext-configure pdo_mysql --with-pdo-mysql; \
    docker-php-ext-configure pdo_pgsql --with-pgsql; \
    docker-php-ext-configure mbstring --enable-mbstring; \
    docker-php-ext-configure soap --enable-soap; \
    #
    # Install php extensions
    docker-php-ext-install \
    bcmath \
    calendar \
    ctype \
    curl \
    dba \
    dom \
    exif \
    fileinfo \
    ftp \
    gettext \
    gmp \
    hash \
    iconv \
    imap \
    interbase \
    intl \
    json \
    ldap \
    mbstring \
    mysqli \
    opcache \
    pcntl \
    pdo \
    pdo_firebird \
    pdo_mysql \
    pdo_pgsql \
    pdo_sqlite \
    pgsql \
    phar \
    posix \
    pspell \
    recode \
    session \
    shmop \
    simplexml \
    soap \
    sockets \
    sysvmsg \
    sysvsem \
    sysvshm \
    tidy \
    tokenizer \
    wddx \
    xml \
    xmlrpc \
    xmlwriter \
    xsl \
    zip \
    -j$(nproc) intl gd; \
    ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/local/include/; \
    #
    # Setup php extensions via pecl
    yes | pecl install imagick xdebug mongodb; \
    docker-php-ext-enable mysqli pdo_mysql pdo_firebird pdo_pgsql imagick xdebug mongodb; \
    usermod -u 1000 www-data; \
    rm -rf /var/lib/apt/lists/*;

EXPOSE 9000
CMD ["php-fpm"]
