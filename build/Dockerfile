FROM alpine
RUN apk add --no-cache \
  openssh \
  openssh-server-pam \
  bash \
  rsync \
  shadow

COPY get_pub_keys.sh update_users.sh run_ssh_box.sh /usr/local/sbin/
CMD bash /usr/local/sbin/run_ssh_box.sh

