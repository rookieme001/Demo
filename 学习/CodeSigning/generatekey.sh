#!/bin/sh
function generatekeyKey() {
	openssl genrsa -out $1_private_key.pem 1024
	openssl pkcs8 -topk8 -inform PEM -in $1_private_key.pem -outform PEM -nocrypt -out $1_private_key_pkcs8.pem
	openssl rsa -in $1_private_key.pem -pubout -out $1_public_key.pem
}

cd Demo/CodeSigning/CodeSigning/Keys

generatekeyKey mac
generatekeyKey apple


