#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x

CONF='/etc/letsencrypt'
ACME_CHALLENGES='/var/www/challenges'
ACCOUNT_KEY="$CONF/le_account.key"
CA_FILE="$CONF/lets-encrypt-x3-cross-signed.pem"

[ ! -d "$CONF" ] && echo "Conf dir does not exist" && exit 128

# Either --all or <domain1> <domain2>
if [ "$1" == "--all" ]; then
    DOMAINS=$(find $CONF -name '*.csr' -exec basename {} .csr \;)
else
    DOMAINS=$@
fi

if [ ! -f "$ACCOUNT_KEY" ]; then
    echo ">> Generating Lets Encrypt Account Key"
    openssl genrsa 4096 > $ACCOUNT_KEY 
    chmod 600 $ACCOUNT_KEY
fi

if [ ! -f "$CA_FILE" ]; then
    echo ">> Downloading CA File"
    curl -L 'https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem' -o $CA_FILE
fi

for DOMAIN in $DOMAINS; do
    
    DOMAIN_CRT="$CONF/${DOMAIN}.crt"
    DOMAIN_KEY="$CONF/${DOMAIN}.key"
    DOMAIN_CSR="$CONF/${DOMAIN}.csr"
    DOMAIN_PEM="$CONF/${DOMAIN}.pem"

    if [ ! -f "$DOMAIN_KEY" ]; then
        echo ">> Generating Key for $DOMAIN"
        openssl genrsa 2048 > $DOMAIN_KEY
        chmod 600 $DOMAIN_KEY
    fi

    if [ ! -f "$DOMAIN_CSR" ]; then
        echo ">> Generating CSR for $DOMAIN"
        openssl req -new -sha256 -key $DOMAIN_KEY -subj "/CN=${DOMAIN}" > $DOMAIN_CSR
    fi

    echo ">> Running ACME for $DOMAIN"
    python /acme_tiny.py --account-key $ACCOUNT_KEY --csr $DOMAIN_CSR --acme-dir $ACME_CHALLENGES > $DOMAIN_CRT

    echo ">> Generating concatenated PEM"
    touch $DOMAIN_PEM && chmod 600 $DOMAIN_PEM
    cat $DOMAIN_KEY $DOMAIN_CRT $CA_FILE > $DOMAIN_PEM

done
echo ">> All done"
