FROM php:7-apache

ENV WEBTREES_VERSION 2.0.9

WORKDIR /

RUN apt-get update \
    && apt-get install -y wget \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    && rm -rf /var/lib/apt/lists/*
    
RUN wget https://github.com/fisharebest/webtrees/archive/$WEBTREES_VERSION.zip \
    && unzip $WEBTREES_VERSION.zip \
    && rm $WEBTREES_VERSION.zip
    
RUN mv webtrees-$WEBTREES_VERSION/* /var/www/html/

RUN docker-php-ext-install -j$(nproc) pdo_mysql \
    && docker-php-ext-configure gd #--with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install -j$(nproc) exif \
    && docker-php-ext-install -j$(nproc) intl \
    && docker-php-ext-install -j$(nproc) zip

VOLUME /var/www/html/data

# Enable Logs
RUN cp $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini

# Generate SSL stuff
RUN rm /etc/apache2/sites-enabled/000-default.conf

RUN openssl req -x509 -nodes -days 36500 -newkey rsa:4096 -keyout /etc/ssl/selfsigned.key -out /etc/ssl/selfsigned.crt -subj "/C=AA/ST=AA/L=Internet/O=Docker/OU=www.simonszu.de/CN=selfsigned" \
    && a2enmod ssl

ADD vhost-ssl.conf /etc/apache2/sites-enabled/


ADD run.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run.sh
ADD messages.po /var/www/html/resources/lang/de

RUN chown -R www-data:root /var/www/html/

EXPOSE 443
ENTRYPOINT ["/usr/local/bin/run.sh"]
