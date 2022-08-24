#!/bin/bash
set -eu
shopt -s nullglob

echo updating users >&2

function get_pass() {
  # Technically possible to set password from key file
  #set +e
  #grep -q ^'#passwd=' "$1" && {
  #    local newpw=$( grep ^'#passwd=' "$1" | head -n1 )
  #    newpw=${newpw:8}
  #    printf "$newpw"
  #    sed -i 's/^#passwd=.*/#passwd-is-set/' "$1"
  #    return
  #}
  # set -e
  local LENGTH=64
  LC_ALL=C tr -dc A-Za-z0-9 </dev/urandom | head -c $LENGTH
}

function get_readme() {
  cat <<EOF
# SSH Box home

- data/  folder is shared to all users, group access is forced.
- create any other folder to keep files to yourself.
- don't mess things up.

EOF

}

function validate_users() {
  # users uid must be >=2000
  # uid must be unique
  # must be format   [number]-[alphanumeric]
  for file in *; do
    if [[ "$file" =~ ^([0-9]+)-([a-z][a-z0-9_]*)$ ]]; then
      if [[ "${BASH_REMATCH[1]}" -lt 2000 ]]; then
        echo "$file" has UID under 2000 >&2
        exit 1
      fi
    else
      echo files must be formatted " [number]-[alphanumeric]"
      echo "$file" is not valid user definition >&2
      exit 1
    fi
  done
  duplicate_uid=$(
    for file in *; do
      if [[ "$file" =~ ^([0-9]+)-([a-z][a-z0-9_]*)$ ]]; then
        echo "${BASH_REMATCH[1]}"
      fi
    done | sort | uniq -d
  )
  if [[ -n "$duplicate_uid" ]]; then
    echo user definitions contain duplicate UID >&2
    echo "$duplicate_uid" >&2
    exit 1
  fi
}

cd /var/ssh-box/users
validate_users

for file in *; do
  if [[ "$file" =~ ^([0-9]+)-([a-z][a-z0-9_]*)$ ]]; then
    uid=${BASH_REMATCH[1]}
    user=${BASH_REMATCH[2]}
    echo UID: "${BASH_REMATCH[1]}" username: "${BASH_REMATCH[2]}" >&2
    id $user > /dev/null 2>&1 || {
      adduser -D -u $uid $user
      pw=$( get_pass "$file" )
      echo -e "$pw\n$pw" | passwd $user 2> /dev/null
      mkdir -p "/home/$user/data"
      chmod 0711 "/home/$user"
      usermod -a -G box $user
      if grep -q '^# .*trusted.*' "$file"; then
        usermod -a -G trusted $user
      fi
    }
    rm -f "/home/$user/.ssh/authorized_keys"
    get_readme > "/home/$user/README.md"
    chown -R "$user":box "/home/$user/data"
    chmod -R u+rwX,g+rwX,o+X "/home/$user/data"
    chmod 0600 "$file"
    chown $USR "$file"
  fi
done
chmod 0700 /var/ssh-box/users
