FROM alpine:latest

MAINTAINER Andrew Cutler <andrew@panubo.com>
ENV BUILD_DATE=2016-09-02

RUN apk add --update bash curl openssl python && \
    rm -rf /var/cache/apk/*

ADD https://raw.githubusercontent.com/diafygi/acme-tiny/master/acme_tiny.py /

RUN chmod +x /*.py

COPY run.sh /

ENTRYPOINT ["/run.sh"]

