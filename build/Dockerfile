FROM alpine
RUN apk add --no-cache \
  openssh \
  openssh-server-pam \
  bash \
  rsync \
  moreutils \
  shadow \
  tzdata

COPY get_pub_keys.sh update_users.sh run_ssh_box.sh /usr/local/sbin/
CMD bash /usr/local/sbin/run_ssh_box.sh

