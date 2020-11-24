FROM php:7.4-cli

# Set TERM to suppress warning messages.
ENV TERM=xterm-256color

# Install composer and put binary into $PATH
#RUN curl -sS https://getcomposer.org/installer \
#      | php --  --install-dir=/usr/bin/  --filename=composer \
#    && mv composer.phar /usr/local/bin/ \
#    && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

# Install additional packages
RUN apt-get update \
    && apt-get install -y \
        apt-utils \
        curl \
        mariadb-client \
        git \
        openssh-client \
        unzip \
        wget \
        curl \
        vim \
        htop \
        build-essential --no-install-recommends \
    && apt-get clean -y

# WDDX
RUN buildDeps=" \
            libicu-dev \
            libpq-dev \
            libmcrypt-dev \
            libldap2-dev \
            libfreetype6-dev  libjpeg62-turbo-dev  libpng-dev \
            libbz2-dev \
            libcurl4-openssl-dev \
            libmemcached-dev \
            libsqlite3-dev  libsqlite3-0 \
            libonig-dev \
            zlib1g-dev \
            libwebp-dev \
            libncurses5-dev \
            libc-client-dev \
            libkrb5-dev \
            libpspell-dev \
            libtidy-dev \
            libxslt-dev \
            libxml2-dev \
        " \
    && apt-get install -y $buildDeps --no-install-recommends \
    && rm -r /var/lib/apt/lists/* \
    && docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
        --with-webp \
    && docker-php-ext-configure imap \
        --with-kerberos \
        --with-imap-ssl \
    && docker-php-ext-configure pdo_mysql \
        --with-pdo-mysql=mysqlnd \
    && docker-php-ext-configure \
        ldap --with-libdir=lib/x86_64-linux-gnu \
    && CFLAGS="-I/usr/src/php"  docker-php-ext-install \
        opcache \
        -j$(nproc) intl \
        bz2 \
        calendar \
        ctype \
        curl \
        dom \
        exif \
        fileinfo \
        ftp \
        -j$(nproc) gd \
        gettext \
        iconv \
        imap \
        intl \
        json \
        ldap \
        pdo \
        pdo_mysql \
            mysqli \
        pdo_sqlite \
        phar \
        posix \
        session \
        shmop \
        simplexml \
        soap \
        sockets \
        sysvmsg  sysvsem  sysvshm \
        tidy \
        tokenizer \
        xml \
        xmlreader \
        xmlrpc \
        xmlwriter \
        xsl

# PHP geoip module
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libgeoip-dev \
    && pecl config-set preferred_state beta \
    && pecl install geoip \
    && echo "extension=geoip.so" > "$(php-config --ini-dir)/docker-pecl-ext-geoip.ini" \
    && rm -rf /var/lib/apt/lists/*

# (i) Only use this, if you want even more up to date timezone data.
# docker-php-ext-install timezonedb \
# @TODO Probably would need a cron job. Updates should get checked at least twice daily.
# pecl upgrade timezonedb
# pecl upgrade intl

# /!\ WDDX is DEPRECATED as of PHP 7.4.0
# @link https://www.php.net/manual/en/intro.wddx.php
# RUN docker-php-ext-configure wddx \
#       --enable-libxml \
#    && docker-php-ext-install wddx

RUN docker-php-source extract \
    && php-config --extension-dir \
    && pecl config-set php_ini $(php-config --ini-dir) \
    && pecl install igbinary \
    && docker-php-ext-enable igbinary \
    && docker-php-source delete \
    && echo "session.serialize_handler=igbinary" > "$(php-config --ini-dir)/docker-php-ext-igbinary.ini" \
    && echo "igbinary.compact_strings=On" >> "$(php-config --ini-dir)/docker-php-ext-igbinary.ini"

# Install php-apcu
RUN pecl install apcu \
    && echo "extension=apcu.so" > "$(php-config --ini-dir)/docker-pecl-ext-apcu.ini" \
    && echo "apc.serializer=igbinary" >> "$(php-config --ini-dir)/docker-pecl-ext-apcu.ini"

RUN docker-php-source extract \
    && pecl install xdebug \
    && docker-php-ext-enable \
        --ini-name=docker-pecl-ext-xdebug.ini \
        xdebug \
    && docker-php-source delete \
    && echo "zend_extension=$(find $(php-config --extension-dir) -name xdebug.so)" > "$(php-config --ini-dir)/docker-pecl-ext-xdebug.ini" \
    && echo "xdebug.mode=debug" >> "$(php-config --ini-dir)/docker-pecl-ext-xdebug.ini" \
    && echo "xdebug.remote_autostart=off" >> "$(php-config --ini-dir)/docker-pecl-ext-xdebug.ini" \
    && echo "xdebug.client_port=9003" >> "$(php-config --ini-dir)/docker-pecl-ext-xdebug.ini" \
    && echo "xdebug.discover_client_host=0" >> "$(php-config --ini-dir)/docker-pecl-ext-xdebug.ini"

# Clean system
RUN apt-get purge --auto-remove -y $buildDeps \
    && apt-get autoremove -y \
    && rm -rf /tmp/* /var/tmp/* \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# DEVELOPMENT BUILD
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

RUN echo -n "\n ------------\n PHP installed using to following configuration:\n ------------\n" \
    && php-config --configure-options | tr " " "\n"

WORKDIR /usr/src/xmlsitemap

CMD [ "php", "run.php" ]