# Dockerized SSH box


First start:

- copy example-env to .env
- Edit the file:
  - modify your user ID number as USR
  - EXPOSE to port exposed outside

- start with docker-compose, or by using `make`
- data/ folder appears. It contains users definitions, and home folders
- create user by adding authorized_keys contents to data/users/[UID]-[username] file
  - example:  `vim users/2000-user1`  <- copy id_rsa.pub contents there
- use UID >=2000
- you can also use the `user-add` script

