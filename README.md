# Docker ACME

[![Docker Repository on Quay](https://quay.io/repository/panubo/acme/status "Docker Repository on Quay")](https://quay.io/repository/panubo/acme)

Docker container for Let's Encrypt [ACME tiny client](https://github.com/diafygi/acme-tiny).

## Example  Usage

If you keep a script `acme.sh` on your host with the following:

```
#!/usr/bin/env bash

docker run --rm -t -i \
  -v /mnt/data00/nginx.service/ssl:/etc/letsencrypt:z \
  -v /mnt/data00/nginx.service/challenges:/var/www/challenges:z \
  quay.io/panubo/acme $@
  ```

Then you can issue certs with one command:

```
[root@docker-host ~]# acme.sh --issue test.example.com
>> Generating Key for test.example.com
Generating RSA private key, 2048 bit long modulus
................+++
.................................................+++
e is 65537 (0x10001)
>> Generating CSR for test.example.com
>> Running ACME for test.example.com
Parsing account key...
Parsing CSR...
Registering account...
Already registered!
Verifying test.example.com...
test.example.com verified!
Signing certificate...
Certificate signed!
>> Generating concatenated PEM
>> All done
```
