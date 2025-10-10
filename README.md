# SimplePKI

## Table of contents
* [Description](#description)
* [Dependencies](#dependencies)
* [Setup](#setup)
* [Usage](#usage)

## Description
Simple-PKI is a bash shell based command wrapper for openssl to simplify the generation and maintenance of CAs and the needed operations. It additionally adds an layer of transparency by adding the possibility to create an overview HTML page for status information to propagate it through a webserver.

To run the script you need to make it executable. It can be run in a non-provileged context. Further information can be obtained from the 'Usage' part.

Supported functions:

* Create CA (Root & Intermediate CA)
* Create private keys with different algorithms
* Create certificate requests with different usages
* Sign certificates with different usages
* Revoke certifikates
* Create CRL
* Buffer / copy CRL
* Create a HTML overview status page

The Project is written as a GNU bash shell script.

## Dependencies
| Dependency            | Version (verified)                    | Necessity     | Used Command Binary                                                                                                                   |
|:----------------------|:--------------------------------------|:-------------:|:-------------------------------------------------------------------------------------------------------------------------------------:|
| GNU bash              | >= 5.3.3(1)                           | necessary     | bash                                                                                                                                  |
| GNU Awk               | >= 5.3.2                              | necessary     | awk                                                                                                                                   |
| GNU Coreutils         | >= 9.7.1                              | necessary     | date & dd & dirname & env & echo & false & mkdir & realpath & rm & sed & seq & tail & tee & touch & test & true & unset & wc & whoami |
| GNU findutils         | >= 4.10.0                             | necessary     | xargs                                                                                                                                 |
| grep                  | >= 3.12                               | necessary     | grep                                                                                                                                  |
| openssl               | >= 3.5.3                              | necessary     | openssl                                                                                                                               |
| sed                   | >= 4.9                                | necessary     | sed                                                                                                                                   |
| whereis               | >= 2.41.2                             | necessary     | whereis                                                                                                                               |

## Setup
To run this project, you need to clone it to your local computer and run it as a shell script.

```
$ cd /tmp
$ git clone https://github.com/initd3v/simplepki.git
```
## Usage

### Running the script

To run this project, you must add the execution flag for the user context to the bash file. Afterwards execute it in a bash shell. 
After every successful execution the current option configuration will be saved in the download directory.
The log file is located in the download directory.

```
$ chmod u+x /tmp/simplepki/src/pki.sh
$ /tmp/simplepki/src/pki.sh
```

### Syntax

#### Enable Log output (e.g. interactive mode)
export PKI_SCRIPT_OUTPUT=1

#### Syntax Overview

* pki.sh ca_create
* pki.sh cert_create
* pki.sh cert_revoke
* pki.sh crl_create
* pki.sh crl_buffer
* pki.sh key_create
* pki.sh req_create
* pki.sh overview_create

#### Syntax Description

* all parameters are in a key/value pair syntax (PARAMETER=VALUE)
* multiple parameters are separated by three colons (:::)

| Command               | Parameter                             | Necessity     | Description                                                                                                                           |
|:----------------------|:--------------------------------------|:-------------:|:-------------------------------------------------------------------------------------------------------------------------------------:|
| ca_create             | PKI_CA_OUTPUT_PATH                    | necessary     | Output path of the CA folder / file structure which must be readable / writable by executing user.                                    |
|                       | PKI_CA_NAME                           | necessary     | Name of the generated CA consisting of 4 to 32 letters or numbers which is also included in various files.                            |
|                       | PKI_CA_ROOT                           | necessary     | Number which indicates if the generated CA is a ROOT (value: 1) or an INTERMEDIATE (value: 0) CA.                                     |
|                       | PKI_CA_BASE_URI                       | necessary     | URI which is used in various configuration file entries as base URI (e.g. CRL: PKI_CA_BASE_URI/PKI_CA_NAME/PKI_CA_NAME.crl).          |
|                       | PKI_CA_POLICY                         | necessary     | OID representing the CA policy.                                                                                                       |
|                       | PKI_CA_CERT_POLICY                    | necessary     | OID representing the certificate policy.                                                                                              |
|                       | PKI_KEY_ALGORITHM                     | necessary     | Encryption algorithm 'ec', 'rsa' or 'ed25519'.                                                                                        |
|                       | PKI_KEY_ENCRYPTION                    | necessary     | Encryption algorithm depth definition (ec -> prime256v1 or prime384v1 or prime521v1, rsa -> 3072 or 4096 or 8192).                    |
|                       | PKI_KEY_PASSWORD                      | necessary     | Encryption password of the key.                                                                                                       |
|                       | PKI_REQ_HASH                          | necessary     | Hash algorithm to use for the request (sha256 or sha384 or sha512 or sha512-256 or sha3-256 or sha3-384 or sha3-512).                 |
|                       | PKI_REQ_COUNTRY                       | necessary     | Country name for the request subject consisting of 2 capital letters.                                                                 |
|                       | PKI_REQ_STATE                         | necessary     | State name for the request subject consisting of 2 up to 32 letters.                                                                  |
|                       | PKI_REQ_LOCATION                      | necessary     | Location name for the request subject consisting of 2 up to 32 letters.                                                               |
|                       | PKI_REQ_ORGANIZATION                  | necessary     | Organization name for the request subject consisting of 2 up to 32 letters, numbers, '-' or '.'.                                      |
|                       | PKI_REQ_ORGANIZATIONUNIT              | necessary     | Organization unit name for the request subject consisting of 2 up to 32 letters, numbers, '-' or '.'.                                 |
|                       | PKI_REQ_COMMONNAME                    | necessary     | Common name for the request subject consisting of 2 up to 32 letters, numbers, '@', '.' or ' '.                                       |
|                       | PKI_REQ_EXTENDED_KEY_USAGE            | optional      | The extended key usage for the request (e.g. critical, serverAuth, clientAuth, codeSigning, emailProtection, OCSPSigning)             |
|                       | PKI_REQ_KEY_USAGE                     | necessary     | The extended key usage for the request (e.g. critical, serverAuth, clientAuth, codeSigning, emailProtection, OCSPSigning)             |
|                       | PKI_CERT_DURATION                     | necessary     | The duration of the certificate signing in valid format (1 up to 369 days / 1 up to 59 weeks / 1 up to 12 months / 1 up to 10 years). |
| key_create            | PKI_KEY_OUTPUT_FILE                   | necessary     | Full filepath of the key file to write.                                                                                               |
|                       | PKI_KEY_ALGORITHM                     | necessary     | Encryption algorithm 'ec', 'rsa' or 'ed25519'.                                                                                        |
|                       | PKI_KEY_ENCRYPTION                    | necessary     | Encryption algorithm depth definition (ec -> prime256v1 or prime384v1 or prime521v1, rsa -> 3072 or 4096 or 8192).                    |
|                       | PKI_KEY_PASSWORD                      | necessary     | Encryption password of the key.                                                                                                       |
| req_create            | PKI_REQ_OUTPUT_FILE                   | necessary     | Full filepath of the request file to write.                                                                                           |
|                       | PKI_KEY_INPUT_FILE                    | necessary     | Private key filepath.                                                                                                                 |
|                       | PKI_KEY_INPUT_PASSWORD                | necessary     | Private key encryption password.                                                                                                      |
|                       | PKI_REQ_HASH                          | necessary     | Hash algorithm to use for the request (sha256 or sha384 or sha512 or sha512-256 or sha3-256 or sha3-384 or sha3-512).                 |
|                       | PKI_REQ_COUNTRY                       | necessary     | Country name for the request subject consisting of 2 capital letters.                                                                 |
|                       | PKI_REQ_STATE                         | necessary     | State name for the request subject consisting of 2 up to 32 letters.                                                                  |
|                       | PKI_REQ_LOCATION                      | necessary     | Location name for the request subject consisting of 2 up to 32 letters.                                                               |
|                       | PKI_REQ_ORGANIZATION                  | necessary     | Organization name for the request subject consisting of 2 up to 32 letters, numbers, '-' or '.'.                                      |
|                       | PKI_REQ_ORGANIZATIONUNIT              | necessary     | Organization unit name for the request subject consisting of 2 up to 32 letters, numbers, '-' or '.'.                                 |
|                       | PKI_REQ_COMMONNAME                    | necessary     | Common name for the request subject consisting of 2 up to 32 letters, numbers, '@', '.' or ' '.                                       |
|                       | PKI_REQ_EXTENDED_KEY_USAGE            | optional      | The extended key usage for the request (e.g. critical, serverAuth, clientAuth, codeSigning, emailProtection, OCSPSigning)             |
|                       | PKI_REQ_KEY_USAGE                     | necessar      | The extended key usage for the request (e.g. critical, serverAuth, clientAuth, codeSigning, emailProtection, OCSPSigning)             |
| cert_create           | PKI_CERT_OUTPUT_FILE                  | necessary     | Full filepath of the certificate file to write.                                                                                       |
|                       | PKI_CERT_DURATION                     | necessary     | The duration of the certificate signing in valid format (1 up to 369 days / 1 up to 59 weeks / 1 up to 12 months / 1 up to 10 years). |
|                       | PKI_REQ_INPUT_FILE                    | necessary     | Request filepath which needs to be signed.                                                                                            |
|                       | PKI_KEY_INPUT_FILE                    | necessary     | Private key filepath.                                                                                                                 |
|                       | PKI_KEY_INPUT_PASSWORD                | necessary     | Private key encryption password.                                                                                                      |
|                       | PKI_CA_CONF_FILE                      | necessary     | Full filepath of the configuration file to read.                                                                                      |
|                       | PKI_CA_EXTENSION                      | optional      | CA extension from the CA configuration file which should be used to sign the request. If not specified, request specification is used.|
| cert_revoke           | PKI_CERT_SERIAL                       | necessary     | Certificate serial which should be used to revoke the certificate.                                                                    |
|                       | PKI_KEY_INPUT_FILE                    | necessary     | Private key filepath.                                                                                                                 |
|                       | PKI_KEY_INPUT_PASSWORD                | necessary     | Private key encryption password.                                                                                                      |
|                       | PKI_CA_CONF_FILE                      | necessary     | Full filepath of the configuration file to read.                                                                                      |
|                       | PKI_CERT_REVOKE_REASON                | necessary     | Revoke reason of the certificate (e.g. keyCompromise, CACompromise, superseded).                                                      |
| crl_create            | PKI_CRL_OUTPUT_FILE                   | necessary     | Full filepath of the CRL file to write.                                                                                               |
|                       | PKI_KEY_INPUT_FILE                    | optional      | Private key filepath. Needs to be specified when 'PKI_CERT_INPUT_FILE' is used. Otherwise the CA configuration entries are used.      |
|                       | PKI_CERT_INPUT_FILE                   | optional      | Certificate filepath. Needs to be specified when 'PKI_CERT_INPUT_FILE' is used. Otherwise the CA configuration entries are used.      |
|                       | PKI_KEY_INPUT_PASSWORD                | necessary     | Private key encryption password.                                                                                                      |
|                       | PKI_CA_CONF_FILE                      | necessary     | Full filepath of the configuration file to read.                                                                                      |
|                       | PKI_CRL_DURATION                      | optional      | The duration of the CRL in valid format (1 up to 369 days / 1 up to 59 weeks / 1 up to 12 months / 1 up to 10 years).                 |
| crl_buffer            | PKI_CRL_OUTPUT_FILE                   | necessary     | Full filepath of the CRL file to write the buffer file                                                                                |
|                       | PKI_CRL_INPUT_FILE                    | necessary     | Full filepath of the CRL input file to read.                                                                                          |
| overview_create       | PKI_CA_OVERVIEW_INPUT_CONF_FILE       | necessary     | Full filepath of the CA configuration file to read. Multiple entries are separated by ', '.                                           |
|                       | PKI_CA_OVERVIEW_OUTPUT_PATH           | necessary     | Output path of the 'pki.html' file which must be readable / writable by executing user.                                               |


#### Syntax Examples

```
pki.sh ca_create "PKI_CA_OUTPUT_PATH=/tmp/ca:::PKI_CA_NAME=test:::PKI_CA_ROOT=1:::PKI_CA_BASE_URI=http://pki.test:::PKI_CA_POLICY=1.1.1.1:::PKI_CA_CERT_POLICY=1.1.1.1.2:::PKI_KEY_ALGORITHM=ed25519:::PKI_KEY_PASSWORD=Test1234:::PKI_REQ_HASH=sha512:::PKI_REQ_COUNTRY=US:::PKI_REQ_STATE=California:::PKI_REQ_LOCATION=LA:::PKI_REQ_ORGANIZATION=Test:::PKI_REQ_ORGANIZATIONUNIT=TestSub:::PKI_REQ_COMMONNAME=Test CA:::PKI_REQ_EXTENDED_KEY_USAGE=critical, serverAuth, clientAuth, OCSPSigning:::PKI_CERT_DURATION=10 years"
```
```
pki.sh key_create "PKI_KEY_OUTPUT_FILE=/tmp/test.key:::PKI_KEY_ALGORITHM=rsa:::PKI_KEY_ENCRYPTION=rsa4096:::PKI_KEY_PASSWORD=Test1234"
```
```
pki.sh req_create "PKI_REQ_OUTPUT_FILE=/tmp/test.req:::PKI_KEY_INPUT_FILE=/tmp/test.key:::PKI_KEY_INPUT_PASSWORD=Test1234:::PKI_REQ_HASH=sha256:::PKI_REQ_COUNTRY=US:::PKI_REQ_STATE=California:::PKI_REQ_LOCATION=LA:::PKI_REQ_ORGANIZATION=Test:::PKI_REQ_ORGANIZATIONUNIT=TestSub:::PKI_REQ_COMMONNAME=test.cert:::PKI_REQ_KEY_USAGE=critical, digitalSignature, cRLSign, keyCertSign:::PKI_REQ_ALTERNATE_NAME=IP.1:127.0.0.1"
```
```
pki.sh cert_create "PKI_CERT_OUTPUT_FILE=/tmp/ca/testsub/public/testsub.cer:::PKI_CERT_DURATION=10 years:::PKI_REQ_INPUT_FILE=/tmp/ca/testsub/.private/testsub.req:::PKI_KEY_INPUT_FILE=/tmp/ca/test/.private/test.key:::PKI_KEY_INPUT_PASSWORD=Test1234:::PKI_CA_CONF_FILE=/tmp/ca/test/.private/test.conf:::PKI_CA_EXTENSION=v3_intermediate_ca"
```
```
pki.sh cert_revoke "PKI_CERT_SERIAL=111111111111111111111111111111111:::PKI_KEY_INPUT_FILE=/tmp/ca/testsub/.private/testsub.key:::PKI_KEY_INPUT_PASSWORD=Test1234:::PKI_CA_CONF_FILE=/tmp/ca/testsub/.private/testsub.conf:::PKI_CERT_REVOKE_REASON=superseded"
```
```
pki.sh crl_create "PKI_CRL_OUTPUT_FILE=/tmp/ca/testsub/signing/crls/testsub.crl:::PKI_KEY_INPUT_FILE=/tmp/ca/testsub/.private/testsub.key:::PKI_KEY_INPUT_PASSWORD=Test1234:::PKI_CA_CONF_FILE=/tmp/ca/testsub/.private/testsub.conf:::PKI_CRL_DURATION=7 days"
```
```
pki.sh crl_buffer "PKI_CRL_OUTPUT_PATH=/tmp:::PKI_CRL_INPUT_FILE=/tmp/ca/testsub/signing/crls/testsub.crl"
```
```
pki.sh overview_create "PKI_CA_OVERVIEW_INPUT_CONF_FILE=/tmp/ca/test/.private/test.conf, /tmp/ca/testsub/.private/testsub.conf:::PKI_CA_OVERVIEW_OUTPUT_PATH=/tmp"
```
