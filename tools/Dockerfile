# https://github.com/mongolab/dex

FROM cosmik/web:master

RUN apt-get update \
    && apt-get install --no-install-recommends -yq \
        python-pip \
        python-setuptools \
        python-wheel \
    && apt-get autoremove --purge -yq \
    && rm -rf /var/lib/apt/lists/* \
    && npm config set bin-links false \
    && pip install --upgrade pip \
    && sed -i s/#force_color_prompt=yes/force_color_prompt=yes/ ~/.bashrc

COPY ./tools/bash_history /root/.bash_history

ENV PATH="$PATH:/project/vendor/csmk-it/cosmik/docker/tools/scripts"

CMD /bin/bash
