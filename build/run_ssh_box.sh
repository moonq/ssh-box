#!/bin/bash
set -exu
shopt -s nullglob
basedir=/var/ssh-box/
test -f "$basedir"/ssh-cache/ssh_host_rsa_key || {
  ssh-keygen -A
  grep -v -e AuthorizedKeys -e PermitEmptyPasswords -e PasswordAuthentication \
    -e Subsystem \
    /etc/ssh/sshd_config > /etc/ssh/sshd_config.tmp
  mv /etc/ssh/sshd_config.tmp /etc/ssh/sshd_config
  cat <<EOF >> /etc/ssh/sshd_config
AuthorizedKeysFile    /tmp/empty_keys
AuthorizedKeysCommand /usr/local/sbin/get_pub_keys.sh
AuthorizedKeysCommandUser root
PermitEmptyPasswords no
PasswordAuthentication no
Subsystem sftp /usr/lib/ssh/sftp-server -u 002
EOF
  rsync -va /etc/ssh/ "$basedir"/ssh-cache/
}
mkdir -p "$basedir"/users "$basedir"/ssh-cache "$basedir"/home
rsync -va --del "$basedir"/ssh-cache/ /etc/ssh/
chown -R $USR "$basedir"/users "$basedir"/ssh-cache
chown -R root:root /etc/ssh/
chmod 0644 /etc/ssh/*
chmod 0600 /etc/ssh/*key
chmod 0700 "$basedir"/ssh-cache/ "$basedir"/users/
chmod 0600 "$basedir"/ssh-cache/*
chmod 0711 "$basedir"

if getent group box; then
  echo Group already added
else
  groupadd -g $GRP box
fi
if getent group trusted; then
  echo Trusted already added
else
  groupadd trusted
fi


rmdir /home || true
chown root:trusted "$basedir"/home
chmod 0751 "$basedir"/home
ln -sfT "$basedir"/home /home

touch /tmp/empty_keys
chmod 0200 /tmp/empty_keys

chown root:root /usr/local/sbin/*.sh
chmod 0700 /usr/local/sbin/*.sh

cat <<EOF > /etc/profile
alias ll='ls -al'
EOF

echo "$NAME" > /etc/motd

update_users.sh

"/usr/sbin/sshd" "-D" "-e" "-f" "/etc/ssh/sshd_config"
