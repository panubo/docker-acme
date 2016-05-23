FROM alpine:latest

MAINTAINER Andrew Cutler <andrew@panubo.com>

RUN apk update && \
    apk add bash curl openssl python && \
    rm -rf /var/cache/apk/*

ADD https://raw.githubusercontent.com/diafygi/acme-tiny/master/acme_tiny.py /

RUN chmod +x /acme_tiny.py

COPY run.sh /

ENTRYPOINT ["/run.sh"]

