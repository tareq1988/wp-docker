# Makefile for Docker Nginx PHP Composer MySQL
# Ref: https://github.com/nanoninja/docker-nginx-php-mysql/blob/master/Makefile

include .env

# MySQL
MYSQL_DUMPS_DIR=data/dumps

help:
	@echo ""
	@echo "usage: make COMMAND"
	@echo ""
	@echo "Commands:"
	@echo "  install             Install the platform"
	@echo "  code-sniff          Check the API with PHP Code Sniffer (PSR2)"
	@echo "  clean               Clean directories for reset"
	@echo "  composer-up         Update PHP dependencies with composer"
	@echo "  docker-start        Create and start containers"
	@echo "  docker-stop         Stop and clear all services"
	@echo "  gen-certs           Generate SSL certificates"
	@echo "  logs                Follow log output"
	@echo "  mysql-dump          Create backup of whole database"
	@echo "  mysql-restore       Restore backup from whole database"
	@echo "  test                Test application"

install:
	@docker-compose build
	composer create-project roots/bedrock src

install-plugins:
	composer require wpackagist-plugin/disable-emojis --working-dir=$(shell pwd)/src
	composer require wpackagist-plugin/nginx-cache --working-dir=$(shell pwd)/src
	composer require wpackagist-plugin/redis-cache --working-dir=$(shell pwd)/src
	composer require wpackagist-plugin/debug-bar --working-dir=$(shell pwd)/src
	composer require wpackagist-plugin/query-monitor --working-dir=$(shell pwd)/src
	curl -o $(shell pwd)/src/web/app/object-cache.php https://raw.githubusercontent.com/tillkruss/redis-cache/master/includes/object-cache.php

clean:
	@rm -Rf data/mysql/*
	@rm -Rf data/logs/*
	@rm -Rf data/nginx-cache/*
	@rm -Rf $(MYSQL_DUMPS_DIR)/*
	@rm -Rf src/web/app/uploads/*
	@rm -Rf src/web/app/plugins/*
	@rm -Rf src/web/app/themes/*

code-sniff:
	@echo "Checking the standard code..."
	@docker-compose exec -T php ./app/vendor/bin/phpcs -v --standard=PSR2 app/src

composer-up:
	@docker run --rm -v $(shell pwd)/src:/app composer update

docker-start:
	docker-compose up -d

docker-stop:
	@docker-compose down -v
	# @make clean

docker-ssh-php:
	docker exec -it php /bin/bash

docker-ssh-nginx:
	docker exec -it nginx /bin/bash

gen-certs:
	@docker run --rm -v $(shell pwd)/etc/ssl:/certificates -e "SERVER=$(NGINX_HOST)" jacoelho/generate-certificate

logs:
	@docker-compose logs -f

mysql-dump:
	@mkdir -p $(MYSQL_DUMPS_DIR)
	@docker exec $(shell docker-compose ps -q mariadb) mysqldump --all-databases -u"$(MYSQL_ROOT_USER)" -p"$(MYSQL_ROOT_PASSWORD)" > $(MYSQL_DUMPS_DIR)/db.sql 2>/dev/null
	@make resetOwner

mysql-restore:
	@docker exec -i $(shell docker-compose ps -q mariadb) mysql -u"$(MYSQL_ROOT_USER)" -p"$(MYSQL_ROOT_PASSWORD)" < $(MYSQL_DUMPS_DIR)/db.sql 2>/dev/null

test: code-sniff
	@docker-compose exec -T php ./app/vendor/bin/phpunit --colors=always --configuration ./app/
	@make resetOwner

resetOwner:
	@$(shell chown -Rf $(SUDO_USER):$(shell id -g -n $(SUDO_USER)) $(MYSQL_DUMPS_DIR) "$(shell pwd)/etc/ssl" "$(shell pwd)/src/web" 2> /dev/null)

# .PHONY: clean test code-sniff init