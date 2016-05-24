#!/usr/bin/env python

# This is not used anymore. To use it the following are required
# $ apk add py-six py-openssl py-cryptography py-enum34 py-cffi

import sys
import OpenSSL.crypto
from OpenSSL.crypto import load_certificate_request, FILETYPE_PEM


# Parse x509 extented CSR for domains list, or return nothing
def main(csr_file):
    with open (csr_file, 'r') as file:
       csr = file.read()
    req = load_certificate_request(FILETYPE_PEM, csr)

    # FIXME: This is brittle
    extensions = req.get_extensions()
    if len(extensions) == 1:
        domains = str(extensions[0]).replace(',','').replace('DNS:','').split(' ')
        for domain in domains:
            print domain


if __name__ == "__main__":
    main(sys.argv[1])
