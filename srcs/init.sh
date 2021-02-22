#!/bin/bash

# Check for autoindex config
if [[ $NGINX_AUTO_INDEX = "on" ]]
then
    # uncomment line 21 in server file.
    sed -i '21s/.*/autoindex on;/' /tmp/ft_server 
elif [[ $NGINX_AUTO_INDEX = "off" ]]
then
    # uncomment line 21 in server file.
    sed -i '21s/.*/autoindex off;/' /tmp/ft_server
fi

# Start services
service mysql start

# Configure a wordpress database
echo "CREATE DATABASE wordpress_db;"| mysql -u root --skip-password
echo "GRANT ALL PRIVILEGES ON wordpress_db.* TO 'root'@'localhost' WITH GRANT OPTION;"| mysql -u root --skip-password
echo "FLUSH PRIVILEGES;"| mysql -u root --skip-password
echo "update mysql.user set plugin='' where user='root';"| mysql -u root --skip-password

# SSL
mkdir -p /etc/ssl/mkcert && cd /etc/ssl/mkcert
mv /tmp/mkcert-v1.1.2-linux-amd64 ./mkcert
chmod +x mkcert
./mkcert -install
./mkcert localhost
cd /tmp

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
