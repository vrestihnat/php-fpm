ARG TARGETARCH
ARG PHP_VERSION=7.4-fpm-alpine3.16

FROM php:${PHP_VERSION}

WORKDIR /web

# packages 
RUN apk add --update --no-cache  .build-deps \
	    $PHPIZE_DEPS \
	    aspell-dev \
	    autoconf \
	    build-base \
	    linux-headers \
	    libaio-dev \
	    zlib-dev \
	    curl \
	    git \
	    subversion \
	    freetype-dev \
	    libjpeg-turbo-dev \
	    libmcrypt-dev \
	    libpng-dev \
	    libtool \
	    libbz2 \
	    bzip2-dev \
	    libstdc++ \
	    libxslt-dev \
	    openldap-dev \
	    imagemagick-dev \
	    hiredis-dev \
	    make \
	    unzip \
	    ffmpeg \
	    wget && \
	    imagemagick \
	    libmemcached-dev \
	    libtool \
	    zlib-dev \
	    freetype \
	    libjpeg-turbo \
	    libpng \
	    && docker-php-ext-configure gd \
	    --with-freetype=/usr/include/ \
	    --with-jpeg=/usr/include/ \
	    && docker-php-ext-install -j$(nproc) gd \
	    && docker-php-ext-enable gd \
	    && apk del --no-cache \
	    freetype-dev \
	    libjpeg-turbo-dev \
	    libpng-dev \
	    && apk add --update --no-cache .zip-runtime-deps libzip-dev \
	    && docker-php-ext-install zip \
	    \
# install postgresql
	    && apk add --update --no-cache  .postgresql-runtime-deps postgresql-dev \
		    && docker-php-ext-install pgsql pdo_pgsql \
		    \
# Install imagick
		    && apk add --update --no-cache .imagick-runtime-deps imagemagick \
			    && pecl install imagick \
			    && docker-php-ext-enable imagick \
			    \
# Install redis
			    && pecl install redis-5.3.1 \
				    && docker-php-ext-enable redis \
				    \
# Install ffmpeg
				    && apk add --update --no-cache ffmpeg \
					    && rm -rf /tmp/* \
							     && apk del .build-deps \
							     && rm -fr /tmp/pear	


# Register the COMPOSER_HOME environment variable
ENV COMPOSER_HOME /composer

# Add global binary directory to PATH and make sure to re-export it
ENV PATH /composer/vendor/bin:$PATH

# Allow Composer to be run as root
ENV COMPOSER_ALLOW_SUPERUSER 1

# Setup the Composer installer
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }"

RUN php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --snapshot && rm -rf /tmp/composer-setup.php




COPY docker/php-extension.ini /usr/local/etc/php/conf.d/40-extension.ini

COPY docker/php-ini-overrides.ini /usr/local/etc/php/conf.d/50-setting.ini

COPY docker/php-fpm-pool-overrides.conf /usr/local/etc/php-fpm.d/zz-docker.conf

COPY docker/entrypointd.sh /usr/local/bin/entrypointd.sh



#default env
ENV PHP_MEMORY_LIMIT=128M
ENV PHP_DATE_TIMEZONE=Europe/Prague
ENV PHP_EXPOSE_PHP=0
ENV PHP_POST_MAX_SIZE=64M
ENV PHP_OUTPUT_BUFFERING=1
ENV PHP_LOG_ERRORS=1

ENV PHP_UPLOAD_MAX_FILESIZE=100M
ENV PHP_DISPLAY_ERRORS=1
ENV PHP_ZEND_ASSERTION=-1
 
ENV PHPFPM_LISTEN=9000
ENV PHPFPM_LISTEN_OWNER=1000
ENV PHPFPM_LISTEN_GROUP=www-data
ENV PHPFPM_LISTEN_MODE=0666
ENV PHPFPM_LISTEN_BACKLOG=-1
ENV PHPFPM_PM=static
ENV PHPFPM_PM_MAX_CHILDREN=20
ENV PHPFPM_PM_START_SERVERS=50
ENV PHPFPM_PM_MIN_SPARE_SERVERS=10
ENV PHPFPM_PM_MAX_SPARE_SERVERS=50
ENV PHPFPM_PM_MAX_REQUESTS=1000
ENV PHPFPM_REQUEST_TERMINATE_TIMEOUT=30s

ENV PHPFPM_REQUEST_SLOWLOG_TIMEOUT=6s
ENV PHPFPM_SLOWLOG=/var/log/php/php_slowlog.log
ENV PHPFPM_ACCESS_LOG=/var/log/php/fpm-www-access.log
ENV PHPFPM_CLEAR_ENV=no
ENV PHPFPM_CATCH_WORKERS_OUTPUT=yes

ENV PHP_SQLSRV_CLIENT_BUFFER_MAXKBSIZE=524288
ENV OPCACHE_ENABLE=0
ENV OPCACHE_MAX_ACCELERATED_FILES=14000
ENV OPCACHE_REVALIDATE_FREQ=120
ENV OPCACHE_MEMORY_CONSUMPTION=128
ENV OPCACHE_VALIDATE_TIMESTAMP=1



ENTRYPOINT ["docker-php-entrypoint"]
ENTRYPOINT ["sh", "/usr/local/bin/entrypointd.sh"]

EXPOSE 9000

VOLUME /web
WORKDIR /web


CMD ["php-fpm"]
