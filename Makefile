

service-up:
	docker-compose up --build -d -t 1

service-logs:
	docker-compose logs -f -t

service-force-restart:
	docker-compose build
	docker-compose up -d --force-recreate -t 1
	docker-compose logs -f -t

service-down:
	docker-compose down -t 1

service-bash:
	docker-compose exec ssh-ftp-server bash

update-users:
	docker-compose exec ssh-ftp-server update_users.sh
