#!/bin/bash

if [ -z "${IP}" ]; then
  echo "Missing IP, exiting."
  exit 1
fi

if [ -z "${RECORD}" ]; then
  echo "Missing RECORD, exiting."
  exit 1
fi

if [ -z "${DOMAIN}" ]; then
  echo "Missing DOMAIN, exiting."
  exit 1
fi

HOSTED_ZONE=$(aws route53 list-hosted-zones | jq -r ".HostedZones[] | select(.Name==\"${DOMAIN}.\") .Id")

if [ -z "${HOSTED_ZONE}" ]; then
  echo "Unable to find zone for ${DOMAIN}, exiting."
  exit 1
fi

cat change.template | sed -e "s/%IP%/${IP}/g" | sed -e "s/%RECORD%/${RECORD}/g" > change.json
aws route53 change-resource-record-sets --hosted-zone ${HOSTED_ZONE} --change-batch file://change.json
