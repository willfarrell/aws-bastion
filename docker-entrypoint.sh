#!/bin/bash
set -e

# Same as path used in seelog.xml
# TODO Moved to /tmp to allow ECS to have `readonlyRootFilesystem: true`
DIR=/var/log/amazon/ssm/

sleep 1m

CONNECT=$(cat ${DIR}/amazon-ssm-agent.log | grep 'Plugin Port started' | wc -l)
DISCONNECT=$(cat ${DIR}/amazon-ssm-agent.log | grep 'The session was cancelled' | wc -l)

while [ "${DISCONNECT}" -lt "${CONNECT}" ]; do
  echo $((${CONNECT} - ${DISCONNECT})) active
  sleep 1m
  CONNECT=$(cat ${DIR}/amazon-ssm-agent.log | grep 'Plugin Port started' | wc -l)
  DISCONNECT=$(cat ${DIR}/amazon-ssm-agent.log | grep 'The session was cancelled' | wc -l)
done

#ls -al /etc/amazon/ssm/
#ls -al /var/log/amazon/ssm/
#cat ${DIR}/amazon-ssm-agent.log
#cat ${DIR}/errors.log

echo "No active connections. Shutting down."
