#!/bin/bash
set -e
idnr=$( id -u "$1" )

if [[ -e "/var/ssh-box/users/${idnr}-${1}" ]]; then
  cat "/var/ssh-box/users/${idnr}-${1}"
fi

