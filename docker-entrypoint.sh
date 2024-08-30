#!/bin/bash
set -e

sleep 1m

CONNECT=$(cat /var/log/amazon/ssm/amazon-ssm-agent.log | grep 'Plugin Port started' | wc -l)
DISCONNECT=$(cat /var/log/amazon/ssm/amazon-ssm-agent.log | grep 'Session worker closed' | wc -l)

while [ "${DISCONNECT}" -lt "${CONNECT}" ]; do
  echo $((${CONNECT} - ${DISCONNECT})) active
  sleep 1m
done

cat /var/log/amazon/ssm/amazon-ssm-agent.log
cat /var/log/amazon/ssm/errors.log
