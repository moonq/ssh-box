FROM alpine
RUN apk add --no-cache \
  openssh \
  openssh-server-pam \
  bash \
  rsync \
  shadow

ADD get_pub_keys.sh /usr/local/sbin/get_pub_keys.sh
ADD update_users.sh /usr/local/sbin/update_users.sh
ADD run.sh /usr/local/sbin/run_ssh_box.sh
CMD bash /usr/local/sbin/run_ssh_box.sh

