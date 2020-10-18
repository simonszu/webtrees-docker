FROM php:7-apache

ENV WEBTREES_VERSION 2.0.9

WORKDIR /

# Generate SSL stuff
RUN rm /etc/apache2/sites-enabled/000-default.conf

RUN openssl req -x509 -nodes -days 36500 -newkey rsa:4096 -keyout /etc/ssl/selfsigned.key -out /etc/ssl/selfsigned.crt -subj "/C=AA/ST=AA/L=Internet/O=Docker/OU=www.simonszu.de/CN=selfsigned" \
    && a2enmod ssl

ADD vhost-ssl.conf /etc/apache2/sites-enabled/

RUN apt-get update \
    && apt-get install -y wget \
    unzip \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libwebp-dev \
    libxpm-dev \
    libz-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*
    
RUN docker-php-ext-install pdo_mysql \
    && docker-php-ext-install exif \
    && docker-php-ext-install intl \
    && docker-php-ext-install zip
    
RUN docker-php-ext-configure gd --with-gd --with-webp-dir --with-jpeg-dir \
    --with-png-dir --with-zlib-dir --with-xpm-dir --with-freetype-dir \
    --enable-gd-native-ttf
RUN docker-php-ext-install gd 
    
RUN wget https://github.com/fisharebest/webtrees/archive/$WEBTREES_VERSION.zip \
    && unzip $WEBTREES_VERSION.zip \
    && rm $WEBTREES_VERSION.zip
    
RUN mv webtrees-$WEBTREES_VERSION/* /var/www/html/

VOLUME /var/www/html/data

# Enable Logs
#RUN cp $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini

ADD run.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run.sh
ADD messages.po /var/www/html/resources/lang/de

RUN chown -R www-data:root /var/www/html/

EXPOSE 443
ENTRYPOINT ["/usr/local/bin/run.sh"]
