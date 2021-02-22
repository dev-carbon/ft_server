#!/bin/bash

# Check for autoindex config
if [[ $NGINX_AUTOINDEX = "on" ]]
then
    # uncomment line 21 in server file.
    sed -i 's/autoindex off/autoindex on/g' /tmp/ft_server 
elif [[ $NGINX_AUTOINDEX = "off" ]]
then
    # uncomment line 21 in server file.
    sed -i 's/autoindex on/autoindex off/g' /tmp/ft_server
fi

# Start services
service mysql start

# Configure a wordpress database
echo "CREATE DATABASE wordpress_db;"| mysql -u root --skip-password
echo "GRANT ALL PRIVILEGES ON wordpress_db.* TO 'root'@'localhost' WITH GRANT OPTION;"| mysql -u root --skip-password
echo "FLUSH PRIVILEGES;"| mysql -u root --skip-password
echo "update mysql.user set plugin='' where user='root';"| mysql -u root --skip-password

# SSL
mkdir /etc/nginx/ssl
openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out /etc/nginx/ssl/groovy-wordpress.pem -keyout /etc/nginx/ssl/groovy-wordpress.key -subj "/C=FR/ST=Paris/L=Paris/O=42 School/OU=humanfou/CN=groovy-wordpress"

# Copy nginx default server configuration
rm /etc/nginx/sites-available/default && rm /etc/nginx/sites-enabled/default
mv ./ft_server /etc/nginx/sites-available/.
ln -s /etc/nginx/sites-available/ft_server /etc/nginx/sites-enabled

# Install wordpress
tar xvzf latest.tar.gz
rm -f ./latest.tar.gz
mv ./wordpress /var/www/html/.
mv ./wordpress.config.php /var/www/html/wordpress/wp-config.php

# Install phpmyadmin
tar xvzf phpMyAdmin-5.0.4-all-languages.tar.gz
rm  -f ./phpMyAdmin-5.0.4-all-languages.tar.gz
mv ./phpMyAdmin-5.0.4-all-languages /usr/share/phpmyadmin
mv ./phpmyadmin.config.php /usr/share/phpmyadmin/config.inc.php
ln -s /usr/share/phpmyadmin /var/www/html

# Create info.php file
touch /var/www/html/info.php
echo "<?php phpinfo(); ?>" > /var/www/html/info.php

service php7.3-fpm start
service nginx restart

bash
