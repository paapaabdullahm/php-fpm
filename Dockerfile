FROM php:7.2.1-fpm

MAINTAINER Abdullah Morgan <paapaabdullahm@gmail.com>
ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 8.9.4

# Setup essential pkgs & libs
RUN wget http://mirrors.kernel.org/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1_amd64.deb; \
    dpkg -i libpng12-0_1.2.54-1ubuntu1_amd64.deb; apt install -f; \
    rm -f libpng12-0_1.2.54-1ubuntu1_amd64.deb; \
    apt update && apt upgrade -y

RUN apt install -y apt-utils \
    libicu-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libxml2-dev \
    libldb-dev \
    libldap2-dev \
    libssl-dev \
    libxslt-dev \
    libpq-dev \
    libmhash-dev \
    mysql-client \
    libsqlite3-dev \
    libsqlite3-0 \
    libc-client-dev \
    libkrb5-dev \
    curl \
    libcurl3 \
    libcurl3-dev \
    firebird-dev \
    libpspell-dev \
    aspell-en \
    aspell-de \
    libtidy-dev \
    librecode0 \
    librecode-dev \
    libgmp-dev \
    libc6 \
    libgmp10 \
    ucf \
    re2c \
    file \
    libmagickwand-dev --no-install-recommends ; \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ ; \
    docker-php-ext-install -j$(nproc) intl gd ; \
    ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/local/include/

RUN docker-php-ext-install opcache
	
RUN yes | pecl install xdebug imagick && docker-php-ext-enable imagick; \
	echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini; \
    echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini; \
    echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini
    
RUN docker-php-ext-install \
    soap \
    ftp \
    xsl \
    bcmath \
    calendar \
    ctype \
    dba \
    dom \
    zip \
    session
    
#RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
    #&& docker-php-ext-install \
    #ldap \
    ##json \
    ##hash \
    ##sockets \
    #pdo \
    #mbstring \
    ##gmp \
    ##tokenizer \
    #pgsql \
    #pdo_pgsql \
    #pdo_mysql \
    #pdo_sqlite \
    #intl \
    #mysqli
    
#RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    #&& docker-php-ext-install \
    #imap \
    #gd \
    #curl \
    ##exif \
    ##fileinfo \
    #gettext \
    ##iconv \
    #interbase \
    #pdo_firebird \
    #opcache \
    ##pcntl \
    ##phar \
    #posix \
    #pspell \
    #recode \
    ##shmop \
    #simplexml \
    ##sysvmsg \
    ##sysvsem \
    ##sysvshm \
    #tidy \
    #wddx \
    #xml \
    #xmlrpc \
    #xmlwriter

RUN yes | pecl install mongodb \
    && echo "extension=mongodb.so" > /usr/local/etc/php/conf.d/ext-mongodb.ini \
    && usermod -u 1000 www-data \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 2000 node \
    && useradd --uid 2000 --gid node --shell /bin/bash --create-home node \
    && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
    && curl -SLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt" \
    && grep "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt | sha256sum -c - \
    && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
    && rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
    && npm install apidoc -g