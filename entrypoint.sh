#!/bin/sh  

# NOTES
# 
# This script setups http.conf and dav.conf configuration files of
# apache and sets the password file for the username:password given 
# 
# The following ENV variables must be set
# DAV_CONF   : the path of dav.conf file
# HTTPD_CONF : the path of the httpd.conf file
# SERVER_NAME: your DNS hostname, or IP address
# PASSWD     : password file for authentication
# REALM      : authentication realm for for digest authentication
# WEBDAV_USERNAME : username of user required for authentcated transactions 
# WEBDAV_PASSWORD : password of user required for authentcated transactions 
# WEBDAV_LOGGIN : LogLevel for httpd (https://httpd.apache.org/docs/2.4/mod/core.html#loglevel)

# modify dav.conf
echo "Seting up $DAV_CONF"
sed -i -e 's#Alias /uploads \"/usr/uploads\"#Alias /uploads \"/uploads\"#g' $DAV_CONF 
sed -i -e 's#/usr/uploads#/uploads#g' $DAV_CONF                 
sed -i -e 's#user admin#valid-user#g' $DAV_CONF                 
sed -i -e 's#<RequireAny>#<LimitExcept GET>#g' $DAV_CONF        
sed -i -e 's#<\/RequireAny>#<\/LimitExcept>#g' $DAV_CONF        
sed -i -e 's#Require method#\#Require method#g' $DAV_CONF       
sed -i -e 's#AuthName DAV-upload#AuthName '"${REALM}"'#g' $DAV_CONF                      
sed -i -e '/<\/Directory>/ a \\n<Directory "/">\n  AuthType None\n  Require all granted\n</Directory>' $DAV_CONF 

echo "Seting up $HTTPD_CONF"
echo "ServerName $SERVER_NAME" >> $HTTPD_CONF  

# create users passwdfiles
if  [ "$BASIC_AUTH" = "True" ]; then
    # basic authentication
    sed -i -e 's#AuthType Digest#AuthType Basic#g' $DAV_CONF
    htpasswd -bc $PASSWD $WEBDAV_USERNAME $WEBDAV_PASSWORD
    echo "Basic authentication has been set"
else
    # digest authentication
    DIGEST="$( printf "%s:%s:%s" "$WEBDAV_USERNAME" "$REALM" "$WEBDAV_PASSWORD" | 
          md5sum | awk '{print $1}' )"
    printf "%s:%s:%s\n" "$WEBDAV_USERNAME" "$REALM" "$DIGEST" >> "$PASSWD"
    echo "Digest authentication has been set"
fi

echo "$DAV_CONF setup finished"
echo "$HTTPD_CONF setup finished"

# change owner and permissions
chmod 640 $PASSWD
chown www-data:www-data $PASSWD

# start httpd
/usr/sbin/httpd -DFOREGROUND -e $WEBDAV_LOGGIN