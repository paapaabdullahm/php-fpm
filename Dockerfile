FROM php:7.2.1-fpm

MAINTAINER Abdullah Morgan <paapaabdullahm@gmail.com>

ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 8.9.4

# Add PHP-FPM and other essential pkgs & libs
RUN wget http://mirrors.kernel.org/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1_amd64.deb; \
    dpkg -i libpng12-0_1.2.54-1ubuntu1_amd64.deb; apt install -f; \
    rm -f libpng12-0_1.2.54-1ubuntu1_amd64.deb \
    && apt update && apt upgrade -y \
	&& apt install -y apt-utils \
	&& apt install -y libicu-dev \
	#
    && docker-php-ext-install -j$(nproc) intl \
	#
    && apt install -y libfreetype6-dev libjpeg62-turbo-dev \
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
	#
    && docker-php-ext-install -j$(nproc) gd \
    #
	&& apt install -y \
        libmcrypt-dev \
        ##php-apc \
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
        libmagickwand-dev \
        --no-install-recommends \
	&& ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/local/include/ \
    #
	#&& docker-php-ext-install \
    #mcrypt \
    #opcache \
    #
	#&& yes | pecl install xdebug imagick && docker-php-ext-enable imagick \
	#&& echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    #&& echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    #&& echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini \
    #
    #&& docker-php-ext-install \
        #soap \
        ##ftp \
        #xsl \
        #bcmath \
        ##calendar \
        ##ctype \
        #dba \
        #dom \
        #zip \
        ##session \
    #
    #&& docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
    #
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
        #intl mysqli \
    #
    #&& docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    #
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
        #xmlwriter \
    #
    && yes | pecl install mongodb \
    && echo "extension=mongodb.so" > /usr/local/etc/php/conf.d/ext-mongodb.ini \
    && usermod -u 1000 www-data \
    && rm -rf /var/lib/apt/lists/*
    
# Add Node JS
RUN groupadd --gid 2000 node \
    && useradd --uid 2000 --gid node --shell /bin/bash --create-home node \
    && set -ex \
    && for key in \
        94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
        FD3A5288F042B6850C66B31F09FE44734EB7990E \
        71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
        DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
        C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
        B9AE9905FFD7803F25714661B63B535A4C206CA9 \
        56730D5401028683275BD23C23EFEFE93C4CFFFE \
        77984A986EBC2AA786BC0F66B01FBB92821C587A \
    ; do \  
        gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
        gpg --keyserver keyserver.pgp.com --recv-keys "$key" || \
        gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" ; \
    done \
    && ARCH= && dpkgArch="$(dpkg --print-architecture)" \
    && case "${dpkgArch##*-}" in \
        amd64) ARCH='x64';; \
        ppc64el) ARCH='ppc64le';; \
        s390x) ARCH='s390x';; \
        arm64) ARCH='arm64';; \
        armhf) ARCH='armv7l';; \
        i386) ARCH='x86';; \
        *) echo "unsupported architecture"; exit 1 ;; \
    esac \
    && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
    && curl -SLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
    && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
    && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
    && npm install apidoc -g
