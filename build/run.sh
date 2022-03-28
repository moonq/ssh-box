#!/bin/bash
set -e
set -x
set -u
basedir=/var/ssh-box/
test -f "$basedir"/ssh-cache/ssh_host_rsa_key || {
    ssh-keygen -A
    grep -v -e AuthorizedKeys -e PermitEmptyPasswords -e PasswordAuthentication \
        /etc/ssh/sshd_config > /etc/ssh/sshd_config.tmp
    mv /etc/ssh/sshd_config.tmp /etc/ssh/sshd_config
    cat <<EOF >> /etc/ssh/sshd_config
AuthorizedKeysFile    /tmp/empty_keys
AuthorizedKeysCommand /usr/local/sbin/get_pub_keys.sh
AuthorizedKeysCommandUser root
PermitEmptyPasswords no
PasswordAuthentication no
EOF
    rsync -va /etc/ssh/ "$basedir"/ssh-cache/
}
mkdir -p "$basedir"/users
rsync -va --del "$basedir"/ssh-cache/ /etc/ssh/
chown -R $USR "$basedir"
chown -R root:root /etc/ssh/
chmod 0644 /etc/ssh/*
chmod 0600 /etc/ssh/*key

if getent group box; then
  echo Group already added
else
  groupadd -g 997 box
fi

chown root:root /home
chmod 0755 /home

touch /tmp/empty_keys
chmod 0200 /tmp/empty_keys

chown root:root /usr/local/sbin/*.sh
chmod 0700 /usr/local/sbin/*.sh

cat <<EOF > /etc/profile
alias ll='ls -al'
EOF

echo "-~''~- SSH-Box ~-..-~" > /etc/motd
echo "$NAME" >> /etc/motd

update_users.sh

"/usr/sbin/sshd" "-D" "-e" "-f" "/etc/ssh/sshd_config"
