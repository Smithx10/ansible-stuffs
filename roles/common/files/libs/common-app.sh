#!/bin/bash

set -eo pipefail

# Assert a variable
assertVariable() {
  local variable=${1}
  
  if [[ -n ${!variable} ]];then 
    _log "The variable ${variable} is set: ${!variable}"
    return 0
  else
    _log "The variable ${variable} is not set"
    return 1
  fi
}

# Return IP for a certain interface
ipDetect() {
  local interface=$1
  
  if assertVariable interface > /dev/null; then
    echo $(ip addr show ${interface}| grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
    return 0
  else
    _log "No Interface Provided"
    return 1 
  fi
}

# Set HTTP_PROXY
setHttpProxy() {
  _log "Attempting to Set http_proxy and https_proxy..."
  assertVariable ONPREMISE_HTTP_PROXY

  if [[ ! -z $(curl -s -m 1 http://169.254.169.254/1.0/) ]]; then
    echo "Provisioning on AWS... Not Setting Proxy"
  else
    echo "Provisioning On-Premise... Setting Proxy to ${ONPREMISE_HTTP_PROXY}"
    export http_proxy=${ONPREMISE_HTTP_PROXY}
    export https_proxy=${ONPREMISE_HTTP_PROXY}
  fi
}

# Standard Bash Logging
_log() {
  #${FUNCNAME[@]:1:${#FUNCNAME[@]}-2}
  local application=${FUNCNAME[@]:1:${#FUNCNAME[@]}-2}
    echo "    $(date -u '+%Y-%m-%d %H:%M:%S') ${application}: $@"
}
