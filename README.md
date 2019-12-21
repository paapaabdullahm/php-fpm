# Dockerized PHP-FPM

PHP-FPM (FastCGI Process Manager) is an alternative PHP FastCGI implementation with some additional features useful for sites of any size, especially busier sites. It also comes bundled with the php cli tool.

## Current Version/Tag: **`v7.4.1`**

> The version with the `latest` tag keeps changing rapidly to mirror the latest PHP release. You are encouraged to pull images tagged with specific versions other than latest, which are more suitable for stable development and production deployments.

## Docker Pull Command

    $ docker pull pam79/php-fpm:v7.4.1

## Usage

#### With docker run

```shell
$ docker run -it --rm --name my-app -v "$PWD":/usr/src/my-app -w /usr/src/my-app pam79/php-fpm:v7.4.1
```
&nbsp;

**To speed up development, let's create two aliases:**

First open your `.bashrc` file. If you are using zsh open your `.zshrc` file instead.
```shell
$ vim ~/.bashrc
```
&nbsp;

Add the following at the bottom of the file. The first alias is for php-fpm while the second is for php cli.
```shell
alias php-fpm="docker run -it --rm -v "$PWD":/usr/src/my-app -w /usr/src/my-app pam79/php-fpm:v7.4.1 php-fpm"
alias php="docker run -it --rm -v "$PWD":/usr/src/my-app -w /usr/src/my-app pam79/php-fpm:v7.4.1 php"
```
&nbsp;

Source the file to reload changes
```shell
$ . ~/.bashrc
```
&nbsp;

**Finally use the alias as regular php-fpm, and php binaries. Here are some examples:**

If you are using it with Laravel, within your project root, you can easily do:
```
$ php artisan foo bar
```

To check the php version you are running, you can either do:
```
$ php-fpm -v
$ php -v
```

To step into an interactive REPL mode you can do:
```
$ php -a
```

To run a script with the cli tool you can simply do:
```
$ php script.php
```

To access phpinfo() from the command line you can do:
```
$ php-fpm -i
$ php -i
```

To run your app with the php internal server, you can do the following, with the -t flag specifying the path to your app:
```
$ php -t . -S <container-ip>:<port>
```

#### With docker-compose

```yml
version: '2.1'

services:
  my-app:
    image: pam79/php-fpm:v7.4.1
    container_name: my-app
    working_dir: /app
    ports:
      - 9000:9000
    volumes:
      - .:/app
    tty: true
```

#### With docker-compose and nginx as proxy

Step 1: Create a network
```
$ docker network create proxy-tier
```

Step 2: cd into your app's directory
```
$ cd my-app
```

Step 3: Create your docker-compose file
```
$ touch docker-compose
```

Step 4: Open file and add the following content to it
```yml
version: '2.1'

services:

  my-app:
    image: pam79/php-fpm:v7.4.1
    container_name: my-app
    working_dir: /usr/share/nginx/html
    volumes:
      - ./:/usr/share/nginx/html:z

  nginx-proxy:
    image: pam79/nginx
    container_name: nginx-proxy
    volumes:
      - ./default.conf:/etc/nginx/conf.d/default.conf
    volumes_from:
      - my-app
    environment:
      - "VIRTUAL_HOST=dev.my-app.com"
    tty: true
    stdin_open: true
    networks:
      - default
    ports:
      - '80:80'
      - '443:443'

networks:
  default:
    external:
      name: proxy-tier
```
> Notice in `volumes` under the `nginx-proxy` service, we've mapped a `default.conf` file from our app into the container which we need to create.

Step 5: Create an nginx default.conf file for your app
```
$ touch default.conf
```

Step 6: Open it and add the following content to it
```nginx
server {
    listen 0.0.0.0:80;
    server_name dev.my-app.com;

    index index.php index.html;
    root /usr/share/nginx/html;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass my-app:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
}
```
> Notice we've substituted the service name `my-app` for the `fastcgi_pass` directive above. Make sure you are using the same name inside the compose file you created previously.

Step 7: Lookup the ip address of your nginx-proxy service
```shell
$ docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nginx-proxy
```
Step 8: Open your /etc/hosts file and append your domain and nginx-proxy ip to it as follows
```
<ip-nginx-proxy>   dev.my-app.com
```

Step 9: Run your app at the foreground or background
```
$ docker-compose up
$ docker-compose up -d
```

Step 10: Visit `http://dev.my-app.com` in your web browser to preview your app.

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
