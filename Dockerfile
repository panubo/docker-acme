FROM alpine:latest

MAINTAINER Andrew Cutler <andrew@panubo.com>

RUN apk add --update bash curl openssl python && \
    rm -rf /var/cache/apk/*

ADD https://raw.githubusercontent.com/diafygi/acme-tiny/master/acme_tiny.py /

RUN chmod +x /*.py

COPY run.sh /

ENTRYPOINT ["/run.sh"]

