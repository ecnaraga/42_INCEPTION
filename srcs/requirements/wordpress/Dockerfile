FROM debian:bullseye

RUN apt update -y ; apt upgrade -y
RUN apt install wget  systemctl -y
RUN apt-get -y install php-cli php-mysql php-curl php-gd php-intl php-fpm
RUN apt-get -y install mariadb-client
RUN wget http://fr.wordpress.org/latest-fr_FR.tar.gz && tar -xzvf latest-fr_FR.tar.gz && rm latest-fr_FR.tar.gz
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod 700 wp-cli.phar
RUN chown -R root:root wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /var/www/html
RUN chown -R www-data:www-data /var/www/html
RUN mv wordpress galambey.42.fr && mv galambey.42.fr /var/www/html

# On definit un nouvel utilisateur pour le rendre proprietaire de ce site
    # Securise le site, si jamais un autre site etait heberge sur ce volume
    # et qu ils n ont pas les memes user-proprietaire mais que un site a une faille
    # ca permet d empecher d avoir acces en ecriture/exec aus autres
    # Cloisonnement du site
RUN adduser wordpress

COPY ./conf/galambey.42.fr.conf /etc/php/7.4/fpm/pool.d/
RUN chown root:root  /etc/php/7.4/fpm/pool.d/galambey.42.fr.conf
RUN chmod 644 /etc/php/7.4/fpm/pool.d/galambey.42.fr.conf

RUN mkdir -p /run/php
RUN chown -R root:root /run/php
RUN chmod 777 /run/php

RUN rm /etc/php/7.4/fpm/pool.d/www.conf

COPY ./conf/wp-config.php /var/www/html/galambey.42.fr
RUN chown -R wordpress:www-data /var/www/html/galambey.42.fr
RUN chmod 710 /var/www/html/galambey.42.fr

COPY ./tools/script.sh .
RUN chown root:root ./script.sh
RUN chmod 700 ./script.sh

CMD ["bash" , "./script.sh" ]