FROM alpine:latest

MAINTAINER Andrew Cutler <andrew@panubo.com>
ENV ACME_TINY_GIT_HASH=9537453586cd5124d5e4e46d78f9ed909180835d

RUN apk add --update bash curl openssl python && \
    rm -rf /var/cache/apk/*

ADD https://raw.githubusercontent.com/diafygi/acme-tiny/${ACME_TINY_GIT_HASH}/acme_tiny.py /

RUN chmod +x /*.py

COPY run.sh /

ENTRYPOINT ["/run.sh"]

