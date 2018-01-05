#!/bin/sh  

# create users passwdfiles
if  [ "$BASIC_AUTH" = "True" ]; then
    # basic authentication
    echo "Basic authentication has been set"
    htpasswd -bc /usr/user.passwd $WEBDAV_USERNAME $WEBDAV_PASSWORD
else
    # digest authentication
    echo "digest authentication has been set"
    DIGEST="$( printf "%s:%s:%s" "$WEBDAV_USERNAME" "$REALM" "$WEBDAV_PASSWORD" | 
          md5sum | awk '{print $1}' )"
    printf "%s:%s:%s\n" "$WEBDAV_USERNAME" "$REALM" "$DIGEST" >> "/usr/user.passwd"
fi

# change owner and permissions
chmod 640 /usr/user.passwd 
chown www-data:www-data /usr/user.passwd

# start httpd
/usr/sbin/httpd -DFOREGROUND -e $WEBDAV_LOGGIN