#!/bin/bash

#TODO: genconfig
/gost-ssl/bin/openssl smime -sign -binary -signer /gost-ssl/ssl/private/provider.pem  -inkey /gost-ssl/ssl/private/provider.pem -outform PEM -in /gost-ssl/php/request.xml -out /gost-ssl/php/request.xml.sign
