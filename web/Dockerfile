FROM ubuntu:18.04

# Let the conatiner know that there is no tty:
ENV DEBIAN_FRONTEND noninteractive
ENV PHPBREW_ROOT /opt/phpbrew
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE 1;

RUN apt-get update -yq \
    && apt-get install --no-install-recommends -yq \
        vim \
        apt-transport-https \
        patch \
        varnish \
        nginx \
        git \
        ca-certificates \
        curl \
        gpg-agent \
        ssh \
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
        libzip-dev \
        dirmngr \
        software-properties-common \
        ffmpeg \
        php-bz2

RUN \
    # Add docker client: \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    # Add nodejs: \
    && curl -sL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh \
    && bash nodesource_setup.sh \
    # Add yarn: \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    # Add mongodb tools: \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 \
    && echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list \
    # Install: \
    && apt-get update -yq \
    && apt-get install --no-install-recommends -yq \
        docker-ce \
        nodejs \
        yarn \
        mongodb-org-tools

RUN \
    # Setup php with dependencies: \
    curl -L -O https://github.com/phpbrew/phpbrew/raw/master/phpbrew \
    && chmod +x phpbrew \
    && mv phpbrew /usr/local/bin/phpbrew \
    && mkdir /opt/phpbrew \
    && phpbrew --no-interact init --root=/opt/phpbrew \
    && echo "source /root/.phpbrew/bashrc" >> /root/.bashrc \
    && /bin/bash -c "source /root/.phpbrew/bashrc \
        && phpbrew --no-interact install --downloader curl -j $(nproc) --production 7.3 as php-7 +default +fpm +intl +iconv +mysql +session \
        && phpbrew --no-interact switch php-7 \
        && export PHPBREW_PHP=php-7"

RUN /bin/bash -c "source /root/.phpbrew/bashrc \
        && phpbrew --no-interact ext install --downloader curl opcache \
        && phpbrew --no-interact ext install --downloader curl apcu \
        && phpbrew --no-interact ext install --downloader curl imagick \
        && phpbrew --no-interact ext install --downloader curl gd -- --with-png-dir=/usr/lib --with-jpeg-dir=/usr/lib \
        && phpbrew --no-interact ext install --downloader curl redis \
        && phpbrew --no-interact ext install --downloader curl mongodb"

RUN \
    # Link php config files for cli and fpm usage: \
    mkdir /opt/phpbrew/php/php-7/etc/cli \
    && mkdir /opt/phpbrew/php/php-7/etc/fpm \
    && for d in /opt/phpbrew/php/php-7/var/db/*; do ln -s "$d" /opt/phpbrew/php/php-7/etc/cli; done \
    && for d in /opt/phpbrew/php/php-7/var/db/*; do ln -s "$d" /opt/phpbrew/php/php-7/etc/fpm; done \
    # Setup composer: \
    && curl https://getcomposer.org/installer | /bin/bash -c "source /root/.phpbrew/bashrc \
        && php -- --install-dir=/usr/local/bin \
        && composer.phar global require hirak/prestissimo" \
    && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer \
    # Remove unneeded packages and apt cache: \
    && apt-get remove --purge -yq build-essential \
    && apt-get autoremove --purge -yq \
    && rm -rf /var/lib/apt/lists/*

ENV PHP_INI_SCAN_DIR /opt/phpbrew/php/php-7/etc/cli

COPY ./web/*.patch /tmp/

RUN touch /etc/nginx/snippets/project.conf \
    && patch /etc/nginx/nginx.conf < /tmp/etc_nginx_nginx.conf.patch \
    && patch /etc/nginx/sites-available/default < /tmp/etc_nginx_sites-available_default.patch \
    && patch /etc/varnish/default.vcl < /tmp/etc_varnish_default.vcl.patch \
    && patch /opt/phpbrew/php/php-7/etc/php-fpm.d/www.conf < /tmp/opt_phpbrew_php_php-7_etc_php-fpm.d_www.conf.patch

WORKDIR /project

EXPOSE 80 8080

COPY ./web/entrypoint.sh /

RUN chmod u+x /entrypoint.sh

CMD /entrypoint.sh
