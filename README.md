## webdav
*****
Docker image for Apache HTTP Server configured with webdav access for Kubernetes deployments. 

Supported tags and respective Dockerfile links:

- [3.7.0-alpine][L37], [latest][Latest]
- [3.6.0-alpine][L36]


 [Latest]: <https://github.com/tapxxor/webdav/blob/master/Dockerfile>
 [L37]: <https://github.com/tapxxor/webdav/blob/alpine-3.7/Dockerfile>
 [L36]: <https://github.com/tapxxor/webdav/blob/alpine-3.6/Dockerfile>

![apache logo](https://raw.githubusercontent.com/docker-library/docs/8e367edd887f5fe876890a0ab4d08806527a1571/httpd/logo.png)


## What is included in this image

* apache server with webdav access (upload directory: "/uploads")
* GET requests do not require authenticated users
* all other method requests (POST, OPTIONS...) should be sent from authentication users
* basic and digest authentication is supported through environmental variable
* requests to servers domain do not require authentication (usefull for server healthcheck)



## How to use this image

For basic authentication set env **BASIC_AUTH** to True. A value different to "True" sets digest authentication. Set the username:password for the authorized user that is allowed to POST files with the envs **WEBDAV_USERNAME** and **WEBDAV_PASSWORD**.

## How run the http server

```console 
$ docker container run --detach --publish 8080:80 -e BASIC_AUTH=False -e WEBDAV_USERNAME=user -e WEBDAV_PASSWORD=pass -e WEBDAV_LOGGIN=info tapxxor/webdav:3.6.0-alpine`
```

* Check startup logs
> ```console
> $ docker container logs <Container ID>
> ```

## Verify that http server is working

```console 
$  curl -s localhost:8080/ -w "%{http_code}\n" -o /dev/null
```
Result: _200_ _(apache root directory is accessible for healthchecks)_

- # Upload a file
*****
```console 
$ echo "Hello from http server" > myfile
```
Result: _OK_ _(myfile with contents "Hello from http server" is created)_

```console 
$ curl -s -T myfile -u user:pass --digest localhost:8080/uploads/ -w "%{http_code}\n" -o /dev/null 
```
Result: _201_ _(an authorized user uploads a file)_

```console 
$ curl -s -T myfile -u tom:hanks --digest localhost:8080/uploads/ -w "%{http_code}\n" -o /dev/null 
```
Result: _401_ _(unauthorized users are not allowed to POST)_

```console 
$ curl -s -T myfile localhost:8080/uploads/ -w "%{http_code}\n" -o /dev/null 
```
Result: _401_ _(must use a user)_

```console 
$ curl -s -T myfile -u user:pass --digest localhost:8080/ -w "%{http_code}\n" -o /dev/null 
```
Result: _405_ _(only /uploads path can accept POST methods)_

- # Get a file 
*****

```console 
$  curl -s -u user:pass --digest localhost:8080/uploads/myfile -w "%{http_code}\n"  
Hello from http server
```
Result:_200_ _(GET a file using an authenticated user succeeds)_

```console 
$  curl -s localhost:8080/uploads/myfile -w "%{http_code}\n"  
Hello from http server
```
_200_ _(GET a file using no user)_

## Configure http server
To configure webdav access modify _/etc/apache2/conf.d/dav.conf_.
Restart httpd application for changes to take effect with:
```console 
$ apachectl restart
```

## Environment Variables
**BASIC_AUTH**
Set to "True" for basic authentications or something different for digest

**WEBDAV_LOGGIN**
LogLevel for httpd (https://httpd.apache.org/docs/2.4/mod/core.html#loglevel)

**WEBDAV_USERNAME**
username of user required for authenticated transactions 

**WEBDAV_PASSWORD**
password of user required for authenticated transactions

## Volumes
You can use volumes for /uploads .