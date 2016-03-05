FROM armhf/php:7.0-apache
MAINTAINER Sean Wilson <spwilson27@gmail.com>

ENV MEDIAWIKI_VERSION 1.26
ENV MEDIAWIKI_FULL_VERSION 1.26.2

#TODO: Look at these
RUN set -x; \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        g++ \
        libicu52 \
        libicu-dev \
    && pecl install intl \
    && echo extension=intl.so >> /usr/local/etc/php/conf.d/ext-intl.ini \
    && apt-get purge -y --auto-remove g++ libicu-dev \
    && rm -rf /var/lib/apt/lists/*

#TODO: Whot is this
RUN docker-php-ext-install mysqli opcache

#TODO: Look at this. 
RUN set -x; \
    apt-get update \
    && apt-get install -y --no-install-recommends imagemagick \
    && rm -rf /var/lib/apt/lists/*

#TODO: Whot is this
RUN a2enmod rewrite

# https://www.mediawiki.org/keys/keys.txt
# TODO: Change
#RUN gpg --keyserver pool.sks-keyservers.net --recv-keys \
#    441276E9CCD15F44F6D97D18C119E1A64D70938E \
#    41B2ABE817ADD3E52BDA946F72BC1C5D23107F8A \
#    162432D9E81C1C618B301EECEE1F663462D84F01 \
#    1D98867E82982C8FE0ABC25F9B69B3109D3BB7B0 \
#    3CEF8262806D3F0B6BA1DBDD7956EE477F901A30 \
#    280DB7845A1DCAC92BB5A00A946B02565DC00AA7

RUN MEDIAWIKI_DOWNLOAD_URL="https://releases.wikimedia.org/mediawiki/$MEDIAWIKI_VERSION/mediawiki-$MEDIAWIKI_FULL_VERSION.tar.gz"; \
    set -x; \
    mkdir -p /usr/src/mediawiki \
    && curl -fSL "$MEDIAWIKI_DOWNLOAD_URL" -o mediawiki.tar.gz \
    && curl -fSL "${MEDIAWIKI_DOWNLOAD_URL}.sig" -o mediawiki.tar.gz.sig \
    && gpg --verify mediawiki.tar.gz.sig \
    && tar -xf mediawiki.tar.gz -C /usr/src/mediawiki --strip-components=1


#TODO: looks at this, looks good just try to understand
COPY apache/mediawiki.conf /etc/apache2/
RUN echo Include /etc/apache2/mediawiki.conf >> /etc/apache2/apache2.conf

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
#TODO might need to change
CMD ["apache2-foreground"]
