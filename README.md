# Overview
A simple *opinionated* PHP 7.2 Docker & Compose Environment for WordPress using Nginx, PHP-FPM, Redis, PHPMyAdmin, Composer, WP CLI and [Bedrock](https://github.com/roots/bedrock).


## Images Used

* [Nginx](https://hub.docker.com/_/nginx/) - Latest
* [Mariadb - Bitnami](https://hub.docker.com/r/bitnami/mariadb/) - Latest
* [PHP-FPM](https://hub.docker.com/_/php/) - Latest (with composer and wp-cli)
* [PHPMyAdmin](https://hub.docker.com/r/phpmyadmin/phpmyadmin/) - Latest
* [Redis](https://hub.docker.com/_/redis/) - Latest


This project use the following ports :

| Server     | Port |
|------------|------|
| MySQL      | 3306 |
| PHPMyAdmin | 8081 |
| Nginx      | 8080 |
| Nginx SSL  | 3000 |
| Redis      | 6379 |

**PHP Extensions:**
date, libxml, openssl, pcre, sqlite3, zlib, ctype, curl, dom, fileinfo, filter, ftp, hash, iconv, json, mbstring, SPL, PDO, bz2, posix, readline, Reflection, session, SimpleXML, pdo_sqlite, standard, tokenizer, xml, xmlreader, xmlwriter, mysqlnd, bcmath, Phar, calendar, gd, intl, mysqli, pdo_mysql, redis, soap, zip, Zend

## Install prerequisites

For now, this project has been mainly created for Unix `(Linux/MacOS)`. Perhaps it could work on Windows.

All requisites should be available for your distribution. The most important are :

* [Composer](https://getcomposer.org/doc/00-intro.md#installation-linux-unix-osx)
* [Git](https://git-scm.com/downloads)
* [Docker](https://docs.docker.com/engine/installation/)
* [Docker Compose](https://docs.docker.com/compose/install/)

## Installation

### Step 0: Clone Repository

Clone this repository in your preferred location.

```sh
git clone https://github.com/tareq1988/wp-docker.git wordpress
cd wordpress
```

### Step 1: Dependency Install

Copy the `.env-example` file to `.env`. It contains the NGINX hostname and MySQL database credentials. After filling that up, run:

```sh
make install
make install-plugins
```

### Step 2: WordPress Configuration

The above command will install the dependencies in place. To complete the WordPress installation, you've to configure the `/src/.env` file for to Bedrock use. Copy the `/src/.env.example` to `/src/.env` file and change the MySQL table and username as configured on the root `.env` file.

**Important:** Set your `DB_HOST` to `mariadb` in the `/src/.env` file.

**Site URL:**
The default WordPress site URL will be `http://wordpress.local:8080` which is defined in the root `.env` file as the Nginx Host `NGINX_HOST=wordpress.local`. If you change this to something else, make sure you also change this value in `/src/.env` file, the `WP_HOME` configuration (`WP_HOME=http://wordpress.local:8080`). The port name has to be appended.

**Application Salt:**
Generate the salt [from the generator](https://roots.io/salts.html) and replace it on `/src/.env` file.

**Configure Host File:**
You've to configure your `/etc/hosts` file to point the site URL to `127.0.0.1`. As we are using `http://wordpress.local` as our hostname, add this config in your `/etc/hosts` file.

```sh
sudo vi /etc/hosts
```

Add config:

```
127.0.0.1	wordpress.local
```

Now save and exit.

### Step 3: Run

Now as all the configuration is done, run the docker instance.

```sh
make docker-start
```

This will simply run docker in detached mode with this command: `docker-compose up -d`

Go to `http://wordpress.local:8080` in your browser and you should see the WordPress installation page.

## WordPress Setup

We are using [Bedrock](https://github.com/roots/bedrock) as our WordPress starter kit.

When using `make install` command, the required dependencies will be installed automatically. With the command `make install-plugins`, the following plugins will be installed as a composer dependency:

- [Disable Emojis](http://wordpress.org/plugin/disable-emojis)
- [Nginx Cache](http://wordpress.org/plugin/nginx-cache)
- [Redis Cache](http://wordpress.org/plugin/redis-cache)
- [Debug Bar](http://wordpress.org/plugin/debug-bar)
- [Query Monitor](http://wordpress.org/plugin/query-monitor)

**Page Cache:**
By default, we will be using **Nginx Fastcgi Cache** and the [Nginx Cache](http://wordpress.org/plugin/nginx-cache) plugin will be the helper to clear the cache. In the plugin settings, you have to save the path to `/var/run/nginx-cache` as the clear path.

If you don't want to use fastcgi cache, edit the `/conf/nginx/site.template.conf` and comment or remove the line `include global/wpfc-php.conf;` and uncomment `include global/php.conf;` file.

**Object Cache:**
We will be using Redis as our persistant object cache backend. The [Redis Cache](http://wordpress.org/plugin/redis-cache) plugin will be used to conditionally clear out the redis cache storage. The command `make install-plugins` will automatically install the plugin and will put the `object-cache.php` in the required location (`/web/app/object-cache.php`).

In order to take the redis cache setup complete, you've to manually add this line `define('WP_REDIS_HOST', 'redis');` in the `/src/config/application.php` file.

## Directory Structure

```
├── Makefile
├── README.md
├── conf					# Nginx, PHP Configuration
│   ├── mysql
│   │   └── my.cnf
│   ├── nginx					
│   │   ├── global/
│   │   ├── nginx.conf
│   │   └── site.template.conf
│   └── php
│       └── php.ini
├── data					# Persistant data directory
│   ├── dumps/
│   ├── logs/
│   ├── mysql
│   │   └── mariadb
│   └── nginx-cache/
├── docker-compose.yml
└── src						# Application Code
    ├── CHANGELOG.md
    ├── CODE_OF_CONDUCT.md
    ├── LICENSE.md
    ├── README.md
    ├── composer.json
    ├── composer.lock
    ├── config
    │   ├── application.php			# Primary wp-config.php
    │   └── environments
    │       ├── development.php
    │       ├── production.php
    │       └── staging.php
    ├── vendor					# Composer dependencies
    │   ├── autoload.php
    │   ├── bin/
    │   ├── composer/
    │   ├── johnpbloch/
    │   ├── oscarotero/
    │   ├── roots/
    │   ├── squizlabs/
    │   └── vlucas/
    ├── web
    │   ├── app/				# WordPress content directory
    │   ├── index.php
    │   ├── wp/					# WordPress core
    │   └── wp-config.php
    └── wp-cli.yml
```


## Use Makefile

When developing, you can use [Makefile](https://en.wikipedia.org/wiki/Make_(software)) for doing the following operations :

| Name          | Description                                |
|---------------|--------------------------------------------|
| install       | Run docker build and install bedrock       |
| install-plugins| Install the required WP plugins           | 
| clean         | Clean directories for reset                |
| docker-start  | Create and start containers                |
| docker-stop   | Stop and clear all services                |
| logs          | Follow log output                          |
| mysql-dump    | Create backup of whole database            |
| mysql-restore | Restore backup from whole database         |

### Examples

Start the application :

```sh
make docker-start
```

Show help :

```sh
make help
```
