FROM ubuntu:16.04

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive
ENV PHPBREW_ROOT /opt/phpbrew

RUN apt-get update -yq \
    && apt-get install --no-install-recommends -yq \
        apt-transport-https \
        patch \
        varnish \
        nginx \
        git \
        ca-certificates \
        curl \
        php \
        pkg-config \
        build-essential \
        autoconf \
        libssl-dev \
        libxml2-dev \
        libbz2-dev \
        libmcrypt-dev \
        libxslt-dev \
        libreadline-dev \
        libmagickwand-dev \
        libmagickcore-dev \
        libcurl4-openssl-dev \
    && curl -L -O https://github.com/phpbrew/phpbrew/raw/master/phpbrew \
    && chmod +x phpbrew \
    && mv phpbrew /usr/local/bin/phpbrew \
    && mkdir /opt/phpbrew \
    && phpbrew --no-interact init --root=/opt/phpbrew \
    && echo "source /root/.phpbrew/bashrc" >> /root/.bashrc \
    && /bin/bash -c "source /root/.phpbrew/bashrc \
        && phpbrew --no-interact install -j $(nproc) --production 7.2 as php-7 +default +fpm +intl -- --enable-maintainer-zts \
        && phpbrew --no-interact switch php-7 \
        && export PHPBREW_PHP=php-7 \
        && phpbrew --no-interact ext install github:krakjoe/pthreads \
        && phpbrew --no-interact ext install apcu \
        && phpbrew --no-interact ext install imagick \
        && phpbrew --no-interact ext install gd \
        && phpbrew --no-interact ext install github:phpredis/phpredis \
        && phpbrew --no-interact ext install mongodb" \
    && mkdir /opt/phpbrew/php/php-7/etc/cli \
    && mkdir /opt/phpbrew/php/php-7/etc/fpm \
    && for d in /opt/phpbrew/php/php-7/var/db/*; do ln -s "$d" /opt/phpbrew/php/php-7/etc/cli; done \
    && for d in /opt/phpbrew/php/php-7/var/db/*; do ln -s "$d" /opt/phpbrew/php/php-7/etc/fpm; done \
    && rm /opt/phpbrew/php/php-7/etc/fpm/pthreads.ini \
    && apt-get remove --purge -yq build-essential git \
    && apt-get autoremove --purge -yq \
    && rm -rf /var/lib/apt/lists/*

ENV PHP_INI_SCAN_DIR /opt/phpbrew/php/php-7/etc/cli

COPY ./web/*.patch /tmp/

RUN touch /etc/nginx/snippets/project.conf \
    && patch /etc/nginx/nginx.conf < /tmp/etc_nginx_nginx.conf.patch \
    && patch /etc/nginx/sites-available/default < /tmp/etc_nginx_sites-available_default.patch \
    && patch /etc/varnish/default.vcl < /tmp/etc_varnish_default.vcl.patch \
    && patch /opt/phpbrew/php/php-7/etc/php.ini < /tmp/opt_phpbrew_php_php-7_etc_php.ini.patch \
    && patch /opt/phpbrew/php/php-7/etc/php-fpm.d/www.conf < /tmp/opt_phpbrew_php_php-7_etc_php-fpm.d_www.conf.patch

WORKDIR /project

EXPOSE 80 8080

COPY ./web/entrypoint.sh /

RUN chmod u+x /entrypoint.sh

CMD /entrypoint.sh