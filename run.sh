#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x

CONF='/etc/letsencrypt'
ACME_CHALLENGES='/var/www/challenges'
ACCOUNT_KEY="$CONF/le_account.key"
CA_FILE="$CONF/lets-encrypt-x3-cross-signed.pem"

[ ! -d "$CONF" ] && echo "Conf dir $CONF does not exist!" && exit 128
[ ! -d "$ACME_CHALLENGES" ] && echo "ACME Challenges dir $ACME_CHALLENGES does not exist!" && exit 128

if [ ! -f "$ACCOUNT_KEY" ]; then
    echo ">> Generating Lets Encrypt Account Key"
    openssl genrsa 4096 > $ACCOUNT_KEY
    chmod 400 $ACCOUNT_KEY
fi

if [ ! -f "$CA_FILE" ]; then
    echo ">> Downloading CA File"
    curl -s -L 'https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem' -o $CA_FILE
fi

function create_csr() {
    PRIMARY_DOMAIN=$1
    DOMAIN_CRT="$CONF/${PRIMARY_DOMAIN}.crt"
    DOMAIN_KEY="$CONF/${PRIMARY_DOMAIN}.key"
    DOMAIN_CSR="$CONF/${PRIMARY_DOMAIN}.csr"
    DOMAIN_PEM="$CONF/${PRIMARY_DOMAIN}.pem"

    for D in $@; do
        SAN="${SAN}DNS:${D} "
    done
    SAN=$(echo $SAN| tr ' ' ,)

    if [ ! -f "$DOMAIN_KEY" ]; then
        echo ">> Generating Key for $PRIMARY_DOMAIN"
        openssl genrsa 2048 > $DOMAIN_KEY
        chmod 600 $DOMAIN_KEY
    fi

    if [ ! -f "$DOMAIN_CSR" ]; then
        echo ">> Generating CSR for $PRIMARY_DOMAIN"
        openssl req -new -sha256 -key $DOMAIN_KEY -subj "/" -reqexts SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=$SAN")) > $DOMAIN_CSR
    fi

    get_cert $PRIMARY_DOMAIN
}

function get_cert() {
    PRIMARY_DOMAIN=$1
    DOMAIN_CRT="$CONF/${PRIMARY_DOMAIN}.crt"
    DOMAIN_KEY="$CONF/${PRIMARY_DOMAIN}.key"
    DOMAIN_CSR="$CONF/${PRIMARY_DOMAIN}.csr"
    DOMAIN_PEM="$CONF/${PRIMARY_DOMAIN}.pem"

    echo ">> Running ACME for $PRIMARY_DOMAIN"
    CRT=$(python /acme_tiny.py --account-key $ACCOUNT_KEY --csr $DOMAIN_CSR --acme-dir $ACME_CHALLENGES)
    [ "$?" -eq "0" ] && (echo "$CRT" > $DOMAIN_CRT)

    echo ">> Generating concatenated PEM"
    touch $DOMAIN_PEM && chmod 600 $DOMAIN_PEM
    cat $DOMAIN_KEY $DOMAIN_CRT $CA_FILE > $DOMAIN_PEM
}

# Either --renew or --issue <domain1> <domain2>
if [ "$1" == "--renew" ]; then
    DOMAINS=$(find $CONF -name '*.csr' -exec basename {} .csr \;)
    for DOMAIN in $DOMAINS; do
        get_cert $DOMAIN
    done
elif [ "$1" == "--issue" ]; then
    shift;
    create_csr $@
else
    echo "Usage Error! See usage for correct arguments."
    echo "Usage: run.sh --renew | --issue <domain1> <domain2>"
    exit 128
fi

echo ">> All done"
