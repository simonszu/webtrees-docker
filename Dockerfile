FROM simonszu/apache-php-ssl

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

#RUN docker-php-ext-install -j$(nproc) pdo_mysql \
#    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
#    && docker-php-ext-install -j$(nproc) gd

#VOLUME /var/www/html/data

ADD run.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run.sh
ADD de.mo /var/www/html/language/

RUN chown -R www-data:root /var/www/html/data

EXPOSE 443
ENTRYPOINT ["/usr/local/bin/run.sh"]
