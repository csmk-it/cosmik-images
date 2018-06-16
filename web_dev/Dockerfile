FROM cosmik/web:master

COPY ./web_dev/*.patch /tmp/

RUN /bin/bash -c "source /root/.phpbrew/bashrc \
        && phpbrew --no-interact ext install xdebug stable" \
    && ln -s /opt/phpbrew/php/php-7/var/db/xdebug.ini /opt/phpbrew/php/php-7/etc/cli/xdebug.ini \
    && ln -s /opt/phpbrew/php/php-7/var/db/xdebug.ini /opt/phpbrew/php/php-7/etc/fpm/xdebug.ini \
    && patch /opt/phpbrew/php/php-7/etc/php.ini < /tmp/opt_phpbrew_php_php-7_etc_php.ini.patch \
    && usermod -u 1000 www-data
    # change user id of www-data to match the id of the docker user in the vm –
    # without this change cache files can not be written running on OS X
