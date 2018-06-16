FROM ubuntu:16.04

RUN apt-get update -yq && apt-get install --no-install-recommends -yq coturn && rm -rf /var/lib/apt/lists/*

CMD turnserver

EXPOSE 3478
EXPOSE 5349
