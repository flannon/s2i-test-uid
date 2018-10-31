#!/bin/bash

# Add default uid to /etc/passwd
#if ! whoami &> /dev/null; then
#  if [ -w /etc/passwd ]; then
#    echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:${HOME}:/sbin/nologin" >> /etc/passwd
#  fi
#fi

[[ ! $(whoami 2> /dev/null) ]] && \
  [[ -w /etc/passwd ]] && \
    echo "${USER_NAME:-runner}:x:$(id -u):0:Container Applicaiton User:${HOME}:/sbin/nologin" >> /etc/passwd
   