## Requirements

* Composer - [install](https://getcomposer.org/doc/00-intro.md#installation-linux-unix-osx)

## Installation

Copy the `.env-example` file to `.env`. It contains the NGINX hostname and MySQL database credentials. After filling that up, run:

```sh
docker-compose build
make install
```


## Use Makefile

When developing, you can use [Makefile](https://en.wikipedia.org/wiki/Make_(software)) for doing the following operations :

| Name          | Description                                |
|---------------|--------------------------------------------|
| apidoc        | Generate documentation of API              |
| clean         | Clean directories for reset                |
| code-sniff    | Check the API with PHP Code Sniffer (PSR2) |
| composer-up   | Update PHP dependencies with composer      |
| docker-start  | Create and start containers                |
| docker-stop   | Stop and clear all services                |
| gen-certs     | Generate SSL certificates for `nginx`      |
| logs          | Follow log output                          |
| mysql-dump    | Create backup of whole database            |
| mysql-restore | Restore backup from whole database         |
| test          | Test application with phpunit              |

### Examples

Start the application :

```sh
make docker-start
```

Show help :

```sh
make help
```

---