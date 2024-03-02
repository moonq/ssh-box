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
mkdir -p "$basedir"/users "$basedir"/ssh-cache "$basedir"/home "$basedir"/log
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
cat <<EOF > /etc/profile
alias ll='ls -al'
EOF
echo "$NAME" > /etc/motd

cat <<EOF > /usr/local/sbin/sshd_start.sh
#!/bin/sh
exec "/usr/sbin/sshd" "-D" "-e" -g 60 "-f" "/etc/ssh/sshd_config" 2>&1 | \
  ts "%b %d %H:%M:%S ${HOSTNAME} sshd[$$]:" >> "${basedir}"/log/sshd.log
EOF

cat <<'EOF' > /usr/local/sbin/sshd_restart.sh
#!/bin/sh
test -e /var/run/sshd.pid && {
    kill `cat /var/run/sshd.pid`
}
/usr/local/sbin/sshd_start.sh &
EOF

cat <<'EOF' > /etc/logrotate.d/sshd
/var/log/sshd.log
{
	rotate 12
	monthly
	missingok
	notifempty
	compress
	delaycompress
	sharedscripts
	postrotate
		[ -x /usr/local/sbin/sshd_restart.sh ] && /usr/local/sbin/sshd_restart.sh || true
	endscript
}
EOF

cat <<'EOF' > /usr/local/sbin/logrotate_weekly.sh
#!/bin/sh
/usr/sbin/logrotate -s /var/log/logrotate.state /etc/logrotate.conf
EOF

ln -sfT /usr/local/sbin/logrotate_weekly.sh /etc/periodic/daily/logrotate_weekly

cat <<'EOF' > /usr/local/sbin/health_check.sh
#!/bin/sh

_fail() {
  echo sshd missing | \
    ts "%b %d %H:%M:%S ${HOSTNAME} health[$$]:" >> /var/log/health.log
  kill -9 -1
}

test -e /var/run/sshd.pid || _fail
test -e /var/run/sshd.pid && {
    sshdpid=$( cat /var/run/sshd.pid )
    test -e /proc/$sshdpid/stat || _fail
}
EOF

ln -sfT /usr/local/sbin/health_check.sh /etc/periodic/15min/health_check

chown root:root /usr/local/sbin/*.sh
chmod 0700 /usr/local/sbin/*.sh

update_users.sh

rmdir /var/log || true
ln -sfT "$basedir"/log /var/log
touch "$basedir"/log/sshd.log
chmod 0600 "$basedir"/log/*

/usr/local/sbin/sshd_restart.sh
crond -f -L "${basedir}/log/cron.log"
