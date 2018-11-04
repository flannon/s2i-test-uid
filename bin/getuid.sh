#!/bin/bash

set -eux

# Add default uid to /etc/passwd
#if ! whoami &> /dev/null; then
#  if [ -w /etc/passwd ]; then
#    echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:${HOME}:/sbin/nologin" >> /etc/passwd
#  fi
#fi

grep default /etc/passwd

[[ ! $(whoami 2> /dev/null) ]] && \
  [[ -w /etc/passwd ]] && \
    echo "${USER_NAME:-builder}:x:$(id -u):0:Container Application User:${HOME}:/sbin/nologin" >> /etc/passwd
   
grep default /etc/passwd
