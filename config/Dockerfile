FROM alpine

VOLUME /config

COPY ["config/run.sh", "config/config.yml", "/"]

#ENV REGISTRY_AUTH_HTPASSWD=htpasswd_content_as_string

RUN apk update && apk add apache2-utils

CMD ["/run.sh"]
