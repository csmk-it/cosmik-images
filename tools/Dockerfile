# https://github.com/mongolab/dex

FROM cosmik/web:master

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 \
    && echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list \
    && apt-get update \
    && apt-get install --no-install-recommends -yq \
        python-pip \
        python-setuptools \
        python-wheel \
        mongodb-org-tools \
    && apt-get autoremove --purge -yq \
    && rm -rf /var/lib/apt/lists/* \
    && npm config set bin-links false \
    && pip install --upgrade pip \
    && sed -i s/#force_color_prompt=yes/force_color_prompt=yes/ ~/.bashrc

COPY ./tools/bash_history /root/.bash_history

ENV PATH="$PATH:/project/vendor/csmk-it/cosmik/docker/tools/scripts"

CMD /bin/bash
