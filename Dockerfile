# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: humanfou <humanfou@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2021/01/11 21:24:17 by humanfou          #+#    #+#              #
#    Updated: 2021/01/21 11:24:13 by humanfou         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:buster

WORKDIR /tmp

RUN apt-get update && apt-get install -y \
    mariadb-server \
    php7.3 php-mysql php-fpm php-pdo php-gd php-cli php-mbstring \
    nginx \
    wget \
    nano \
    libnss3-tools && \
    wget https://github.com/FiloSottile/mkcert/releases/download/v1.1.2/mkcert-v1.1.2-linux-amd64 && \
    wget https://wordpress.org/latest.tar.gz && \
    wget https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-all-languages.tar.gz

COPY ./srcs/phpmyadmin.config.php .
COPY ./srcs/wordpress.config.php .
COPY ./srcs/ft_server .
COPY ./srcs/init.sh .

CMD ["bash", "init.sh"]
