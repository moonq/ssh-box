#!/bin/bash
set -e
shopt -s nullglob

echo updating users >&2

function getpass() {
    # Technically possible to set password from key file
    #set +e
    #grep -q ^'#passwd=' "$1" && {
    #    local newpw=$( grep ^'#passwd=' "$1" | head -n1 )
    #    newpw=${newpw:8}
    #    printf "$newpw"
    #    sed -i 's/^#passwd=.*/#passwd-is-set/' "$1"
    #    return
    #}
    set -e
    local LENGTH=64
    LC_ALL=C tr -dc A-Za-z0-9 </dev/urandom | head -c $LENGTH
}

cd /var/ssh-box/users
for file in *; do
  echo $file
  line=$file
  if [[ "$line" = *".sh" ]]; then
    continue
  fi
  user=${line##*-}
  uid=${line%%-*}
  id $user > /dev/null 2>&1 || {
        adduser -D -u $uid $user
        pw=$( getpass "$file" )
        echo -e "$pw\n$pw" | passwd $user
        mkdir -p "/home/$user/data"
        chmod 0711 "/home/$user"
        usermod -a -G box $user
  }
  rm -f "/home/$user/.ssh/authorized_keys"
  chown -R "$user":box "/home/$user/data"
  chmod -R u+rwX,g+rwX,o+X "/home/$user/data"
done

