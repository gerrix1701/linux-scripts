#!/bin/bash
#
# http monitor script
####################################################
#
# In case a website does not return http code 200
# this script will send a message to a XMPP room
#
# Requirement: go-sendxmpp installed and configured
#
# Set $ROOM and $SITES, run this script via cron
# 
# V0.1 Gerrit <gerrit'at'funzt.one>, Feb. 2025
# - initial release
#
####################################################

# send message to room:
ROOM="<ROOM@XMPP_SERVER>"
# monitor websites:
SITES="<URL1> <URL2> ... <URLN>"

##### nothing to edit below this line #####
DIR="$(dirname "$(readlink -f "$0")")"

for i in ${SITES}; do
  STATUS=`curl -o /dev/null -s -w "%{http_code}" ${i}`
  FILENAME=`echo ${i} | cut -d "/" -f 3`
  if [ ${STATUS} != 200 ] && [ ! -f ${DIR}/${FILENAME}.down ]; then
    echo "${i}: currently down :-(" | /usr/bin/go-sendxmpp --alias=news -t -c ${ROOM}
    touch ${DIR}/${FILENAME}.down || echo "ERROR: cannot write status file ${DIR}/${FILENAME}.down"
  elif [ ${STATUS} == 200 ] && [ -f ${DIR}/${FILENAME}.down ]; then
    echo "${i}: is up again :-)" | /usr/bin/go-sendxmpp --alias=news -t -c ${ROOM}
    rm ${DIR}/${FILENAME}.down || echo "ERROR: cannot remove status file ${DIR}/${FILENAME}.down"
  else
    echo "${i}: no status change"
  fi
done
