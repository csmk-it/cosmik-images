# https://github.com/mongolab/dex

FROM cosmik/web:master

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6 \
    && echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2C52609D \
    && echo "deb http://apt.dockerproject.org/repo ubuntu-xenial main" | tee /etc/apt/sources.list.d/docker.list \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 68576280 \
    && echo "deb https://deb.nodesource.com/node_6.x xenial main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install --no-install-recommends -yq \
        nodejs \
        curl \
        git \
        ssh \
        vim \
        python-pip \
        python-setuptools \
        python-wheel \
        mongodb-org-tools \
        docker-engine \
    && apt-get autoremove --purge -yq \
    && rm -rf /var/lib/apt/lists/* \
    && npm config set bin-links false \
    && pip install dex \
    && curl https://getcomposer.org/installer | /bin/bash -c "source /root/.phpbrew/bashrc && php -- --install-dir=/usr/local/bin" \
    && /bin/bash -c "source /root/.phpbrew/bashrc && composer.phar global require hirak/prestissimo" \
    && sed -i s/#force_color_prompt=yes/force_color_prompt=yes/ ~/.bashrc

COPY ./tools/bash_history /root/.bash_history

ENV PATH="$PATH:/project/vendor/csmk-it/cosmik/docker/tools/scripts"

CMD /bin/bash