FROM php:5.6-apache
MAINTAINER Synctree App Force <appforce+docker@synctree.com>

ENV MEDIAWIKI_VERSION 1.26
ENV MEDIAWIKI_FULL_VERSION 1.26.3
ENV LDAP_VERSION REL1_26


ENV DEBIAN_FRONTEND=noninteractive

RUN set -x; \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        g++ \
        libicu52 \
        libicu-dev \
        libldap2-dev \
        imagemagick \
        git \
    && pecl install intl \
    && echo extension=intl.so >> /usr/local/etc/php/conf.d/ext-intl.ini \
    && apt-get purge -y --auto-remove g++ libicu-dev \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install mysqli opcache

RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/
RUN docker-php-ext-install ldap

RUN a2enmod rewrite

# https://www.mediawiki.org/keys/keys.txt
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys \
    441276E9CCD15F44F6D97D18C119E1A64D70938E \
    41B2ABE817ADD3E52BDA946F72BC1C5D23107F8A \
    162432D9E81C1C618B301EECEE1F663462D84F01 \
    1D98867E82982C8FE0ABC25F9B69B3109D3BB7B0 \
    3CEF8262806D3F0B6BA1DBDD7956EE477F901A30 \
    280DB7845A1DCAC92BB5A00A946B02565DC00AA7

RUN MEDIAWIKI_DOWNLOAD_URL="https://releases.wikimedia.org/mediawiki/$MEDIAWIKI_VERSION/mediawiki-$MEDIAWIKI_FULL_VERSION.tar.gz"; \
    set -x; \
    mkdir -p /usr/src/mediawiki \
    && curl -fSL "$MEDIAWIKI_DOWNLOAD_URL" -o mediawiki.tar.gz \
    && curl -fSL "${MEDIAWIKI_DOWNLOAD_URL}.sig" -o mediawiki.tar.gz.sig \
    && gpg --verify mediawiki.tar.gz.sig \
    && tar -xf mediawiki.tar.gz -C /usr/src/mediawiki --strip-components=1


COPY apache/mediawiki.conf /etc/apache2/
RUN echo Include /etc/apache2/mediawiki.conf >> /etc/apache2/apache2.conf

RUN mkdir /var/tmp/stage && cd /var/tmp/stage && git clone -b $LDAP_VERSION https://github.com/wikimedia/mediawiki-extensions-LdapAuthentication.git
RUN mkdir /var/log/mediawiki

# Install support for emailing.
RUN pear install Auth_SASL
RUN pear install net_smtp
RUN pear install mail

# Read about the LDAP setup here: https://www.mediawiki.org/wiki/Extension:LDAP_Authentication/Requirements
# You basically need to stick your own .crt file in /usr/local/share/ca-certificates and restart the container.
# You can get the certificate by issuing "openssl s_client -showcerts -connect <yourserver>:636"
RUN echo "TLS_CACERTDIR   /etc/ssl/certs" >> /etc/ldap/ldap.conf

VOLUME ["/usr/local/share/ca-certificates"]

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
