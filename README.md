# Dockerized PHP-FPM                                                      
                                                           
PHP-FPM (FastCGI Process Manager) is an alternative PHP FastCGI implementation with some additional features useful for sites of any size, especially busier sites. It also comes bundled with two binaries namely:                           
- php-fpm which is the fast cgi processor, and 
- php which is the command line interface tool

#### Docker Pull Command                                              
    docker pull pam79/php-fpm
                                             
# Usage                                                                    
                                                   
### With docker run                                                      
```shell
$ docker run -it --rm --name my-app -v "$PWD":/usr/src/my-app -w /usr/src/my-app pam79/php-fpm
```
                                             

#### To speed up things, let's create two aliases. One for php-fpm and the other for php cli:                             
                                                                          
First open your '.bashrc' file. If you are using zsh open your '.zshrc' file instead.                          
```shell
$ vim ~/.bashrc
```                                             
                                                          

Add the following at the bottom of the file and save it.                    
```shell
alias php-fpm="docker run -it --rm -v "$PWD":/usr/src/my-app -w /usr/src/my-app pam79/php-fpm php-fpm"
alias php="docker run -it --rm -v "$PWD":/usr/src/my-app -w /usr/src/my-app pam79/php-fpm php"
```
                                    

Source the file to reload changes                                                              
```shell 
$ . ~/.bashrc
```
                                                    

Finally use the alias as regular php-fpm, and php binaries.                  

For example:                                    
- if you are using it with Laravel, within your project root, you can easily do:          
    `$ php artisan foo bar `                                     
                                                                       
- to check the php version you you are running, you can either do:             
    `$ php-fpm -v` or `$ php -v`                                      
                                                      
- to step into an interactive REPL mode you can do:                          
    `$ php -a`                              
                                                               
- to run a script with the cli tool you can simply do:                         
    `$ php script.php`                                   
                                                         
- to find out which php modules are enabled you can do:                        
    `$ php-fpm -i` or                                       
    `$ php -i`                            
                                                           
                                                                          
### With docker-compose
```yml 
version: '2.1'

services:
  my-app:
    image: pam79/php-fpm
    container_name: my-app
    working_dir: /app
    ports:
      - 9000:9000
    volumes:
      - .:/app 
    tty: true
```
                                        

### With docker-compose and nginx proxy                          
                                                       
- Step 1: cd into your app's directory                                                 
    `$ cd my-app`
                                                                  
- Step 2: Create a network                                              
    `$ docker network create proxy-tier`                                       
                                                    
- Step 3: Create your docker-compose file                                
    `$ touch docker-compose`
                                                                 
- Step 4: Open file and save the following content to it                
    
    ```yml 
    version: '2.1'

    services:

      my-app:
        image: pam79/php-fpm
        container_name: my-app
        working_dir: /usr/share/nginx/html
        volumes:
          - ./:/usr/share/nginx/html:z

      nginx-proxy:
        image: pam79/nginx
        container_name: nginx
        volumes:
          - ./default.conf:/etc/nginx/conf.d/default.conf
        volumes_from:
          - my-app
        environment:
          - "VIRTUAL_HOST=my-app.dev"
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
                                                  

- Step 5: Create a default.conf file for nginx                          
    `$ touch default.conf`
                                                   
- Step 7: Add the following content to it                       
    
    ```nginx 
    server {
        listen 0.0.0.0:80;
        server_name my-app.dev;

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
                                                                            

- Step 8: Open your /etc/hosts file and append `my-app.dev` to it as follows    
    `<ip-address>   my-app.dev`                             
                                                                 
    and visit `http://my-app.dev` in your web browser to preview your app.
                                                                    
                                                                     
# Extensions enabled in addition to core                                       

[PHP Modules]                                                       
1. bcmath                                        
2. calendar                                               
3. Core                               
4. ctype                                
5. curl                              
6. date                             
7. dba                            
8. dom                           
9. exif                                
10. fileinfo                            
11. filter                              
12. ftp                                
13. gd                              
14. gettext                        
15. gmp                             
16. hash                       
17. iconv                        
18. imagick                         
19. imap                                            
20. interbase                               
21. intl                                 
22. json                                                    
23. ldap                                    
24. libxml                    
25. mbstring                      
26. mcrypt                       
27. mongodb                     
28. mysqli                            
29. mysqlnd                             
30. openssl                           
31. pcntl                           
32. pcre                         
33. PDO                          
34. PDO_Firebird                              
35. pdo_mysql                        
36. pdo_pgsql                             
37. pdo_sqlite                             
38. pgsql                          
39. Phar                          
40. posix                                      
41. pspell                           
42. readline                          
43. recode                                  
44. Reflection                          
45. session                                 
46. shmop               
47. SimpleXML                        
48. soap                               
49. sockets                        
50. SPL                              
51. sqlite3                             
52. standard                            
53. sysvmsg                                
54. sysvsem                               
55. sysvshm                          
56. tidy                                     
57. tokenizer                                       
58. wddx                               
59. xdebug                                
60. xml                               
61. xmlreader                                           
62. xmlrpc                             
63. xmlwriter                                    
64. xsl                                        
65. Zend OPcache                                     
66. zip                                
67. zlib                                

[Zend Modules]                                                      
1. Xdebug                                                            
2. Zend OPcache                                                    
