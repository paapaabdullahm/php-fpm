# Docker based Laravel PHP-FPM

PHP-FPM (FastCGI Process Manager) is an alternative PHP FastCGI implementation with some additional features useful for sites of any size, especially busier sites.

These features include:

- Adaptive process spawning (NEW!)
- Basic statistics (ala Apache's mod_status) (NEW!)
- Advanced process management with graceful stop/start
- Ability to start workers with different uid/gid/chroot/environment and different php.ini (replaces safe_mode)
- Stdout & stderr logging
- Emergency restart in case of accidental opcode cache destruction
- Accelerated upload support
- Support for a "slowlog"
- Enhancements to FastCGI, such as fastcgi_finish_request() - a special function to finish request & flush all data while continuing to do something time-consuming (video converting, stats processing, etc.)

### The following extensions have been enabled in addition to the core extensions

[PHP Modules]
01. bcmath
02. calendar
03. Core
04. ctype
05. curl
06. date
07. dba
08. dom
09. exif
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
01. Xdebug
02. Zend OPcache
