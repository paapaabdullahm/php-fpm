# Dockerized PHP-FPM

PHP-FPM (FastCGI Process Manager) is an alternative PHP FastCGI implementation with some additional features useful for sites of any size, especially busier sites. It also comes bundled with the php cli tool.

## Current Version/Tag: **`v7.4.1`**

The version with the `latest` tag keeps changing rapidly to mirror the latest PHP release. You are encouraged to pull images tagged with specific versions other than latest, which are more suitable for stable development and production deployments.

## Docker Pull Command
```shell
$ docker pull pam79/php-fpm:v7.4.1
```

## Enabled Extensions
```list
[PHP Modules]
1. bcmath
2. calendar
3. Core
4. ctype
5. curl
6. date
7. dom
8. exif
9. fileinfo
10. filter
11. ftp
12. gd
13. gettext
14. gmp
15. hash
16. iconv
17. igbinary
18. imagick
19. imap
20. intl
21. json
22. ldap
23. libxml
24. mbstring
25. mongodb
26. mysqli
27. mysqlnd
28. openssl
29. pcre
30. PDO
31. pdo_mysql
32. pdo_pgsql
33. pdo_sqlite
34. Phar
35. posix
36. pspell
37. readline
38. redis
39. Reflection
40. session
41. shmop
42. SimpleXML
43. soap
44. sockets
45. sodium
46. SPL
47. sqlite3
48. standard
49. sysvmsg
50. sysvsem
51. sysvshm
52. tidy
53. tokenizer
54. xml
55. xmlreader
56. xmlrpc
57. xmlwriter
58. xsl
59. yaml
60. zip
61. zlib

[Zend Modules]
1. Xdebug
2. Zend OPcache

[Removed Modules]
1. Firebird/Interbase
2. Recode
3. WDDX
```

## Usage

#### With docker run
```shell
$ docker run -it --rm --name my-app -v "$PWD":/usr/src/my-app -w /usr/src/my-app pam79/php-fpm:v7.4.1
```

**To speed up development, let's create two aliases:**

First open your `.bashrc` file. If you are using zsh open your `.zshrc` file instead.
```shell
$ vim ~/.bashrc
```

Add the following at the bottom of the file. The first alias is for php-fpm while the second is for php cli.
```shell
alias php-fpm="docker run -it --rm -v "$PWD":/usr/src/my-app -w /usr/src/my-app pam79/php-fpm:v7.4.1 php-fpm"
alias php="docker run -it --rm -v "$PWD":/usr/src/my-app -w /usr/src/my-app pam79/php-fpm:v7.4.1 php"
```

Source the file to reload changes
```shell
$ . ~/.bashrc
```

**Finally use the alias as regular php-fpm, and php binaries. Here are some examples:**

To check the php version you are running, you can either do:
```shell
$ php-fpm -v
$ php -v
```

To get loaded extensions:
```shell
$ php -m
```

To step into an interactive REPL mode you can do:
```shell
$ php -a
```

To run a script with the cli tool you can simply do:
```shell
$ php script.php
```

To access phpinfo() from the command line you can do:
```shell
$ php-fpm -i
$ php -i
```

To run your app with the php internal server, you can do the following, with the -t flag specifying the path to your app:
```shell
$ php -t . -S container-ip:port
```

If you are using it with Laravel, within your project root, you can easily do:
```shell
$ php artisan foo bar
```

#### With complete docker-compose dev example
Create a new yaml file inside your project webroot
```shell
$ vim docker-compose.yml
```

Add content to the yaml file
```yml
version: '2.4'

services:

  nginx-svc:
    image: pam79/nginx
    working_dir: /usr/share/nginx/html
    volumes:
      - ./default.conf:/etc/nginx/conf.d/default.conf
    volumes_from:
      - app-svc
    tty: true
    stdin_open: true
    depends_on:
      - app-svc
    ports:
      - "80:80"
    networks:
      - proxy-tier
    restart: always

  redis-svc:
    image: redis:alpine
    ports:
      - "6379:6379"
    networks:
      - cache-tier
    restart: always

  app-svc:
    image: pam79/php-fpm
    container_name: app-svc
    working_dir: /usr/share/nginx/html
    volumes:
      - ./:/usr/share/nginx/html
    depends_on:
      - redis-svc
      - mariadb-svc
    environment:
      - "DB_PORT=3306"
      - "DB_HOST=mariadb-svc"
    ports:
      - "9000:9000"
    networks:
      - proxy-tier
      - cache-tier
      - db-tier
    restart: always

  mariadb-svc:
    image: pam79/mariadb
    container_name: mariadb-svc
    volumes:
      - dbdata:/var/lib/mysql
    environment:
      - "MYSQL_DATABASE=myapp"
      - "MYSQL_USER=myapp"
      - "MYSQL_PASSWORD=secret"
      - "MYSQL_ROOT_PASSWORD=rootsecret"
    ports:
      - "3306:3306"
    networks:
      - db-tier
    restart: always

volumes:
  dbdata:
    external:
      name: dbdata

networks:
  proxy-tier:
    external:
      name: proxy-tier
  cache-tier:
    external:
      name: cache-tier
  db-tier:
    external:
      name: db-tier
```

Now let's create our mapped `default.conf` file to be used by the nginx-svc

```shell
$ vim default.conf
```

Add the following content to the default.conf file
   > Note how we used the service name `app-svc` as the value for the `fastcgi_pass` directive below. Make sure you modify it if you are using a different service name.

```nginx
server {
    listen 0.0.0.0:80;
    server_name dev.myapp.com;

    index index.php index.html;
    root /usr/share/nginx/html;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass app-svc:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
}
```

Create external networks
```shell
$ docker network create proxy-tier
$ docker network create cache-tier
$ docker network create db-tier
```

Create external volume
```shell
$ docker volume create dbdata
```

Lookup the ip address of your nginx-svc service
```shell
$ docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nginx-svc
```

Open your /etc/hosts file and append your domain and nginx-svc ip to it as follows
```shell
<ip-of-nginx-svc>   dev.myapp.com
```

To run your app at the foreground
```shell
$ docker-compose up
```

To run your app at the background
```shell
$ docker-compose up -d
```

Finally, visit `http://dev.myapp.com` in your web browser to preview your app. You can also setup [Browsersync](https://www.browsersync.io/) for your project if you want to auto reload your browser whenever you edit your app.
