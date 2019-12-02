FROM alpine:3.10

RUN apk add --update bash curl openssl python && \
    rm -rf /var/cache/apk/*

RUN set -x \
  && ACME_TINY_CHECKSUM=135e2f64083063f9ec9eaf5884e12f77f753489b9ae7d1189c24228cbf3a337b \
  && ACME_TINY_RELEASE=4.1.0 \
  && curl -sSf -L https://github.com/diafygi/acme-tiny/archive/${ACME_TINY_RELEASE}.tar.gz -o /tmp/acme-tiny.tar.gz \
  && printf "%s  %s\n" "${ACME_TINY_CHECKSUM}" "acme-tiny.tar.gz" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM; ) \
  && tar -C /tmp --strip 1 -zxf /tmp/acme-tiny.tar.gz acme-tiny-${ACME_TINY_RELEASE}/acme_tiny.py \
  && mv /tmp/acme_tiny.py / \
  && chmod +x /acme_tiny.py \
  && rm -rf /tmp/* \
  ;

COPY run.sh /

ENTRYPOINT ["/run.sh"]
