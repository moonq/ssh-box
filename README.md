# Dockerized SSH box


First start:

- copy example-env to .env
- Edit the file:
  - modify your user ID number as USR
  - EXPOSE to port exposed outside

- start with docker-compose
- data/ and home/ folders appear
- create user by adding authorized_keys contents to data/users/[UID]-[username] file
  - example:  `vim users/2000-user1`  <- copy id_rsa.pub contents there

