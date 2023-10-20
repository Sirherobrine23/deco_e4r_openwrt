#!/bin/sh

#This script is used to delete token when expired.

expired=$1
token_file=$2

sleep $expired

[ -f $token_file ] && rm -f $token_file

echo "Token expired,delete it." >/dev/console 2>&1