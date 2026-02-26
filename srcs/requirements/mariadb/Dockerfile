FROM debian:bullseye

RUN apt update -y
RUN apt upgrade -y
RUN apt install systemctl -y
RUN apt install mariadb-server mariadb-client -y
COPY ./tools/script.sh .
RUN chown root:root ./script.sh
RUN chmod 777 /script.sh

RUN mkdir -p /var/run/mysqld
RUN chmod 755 /var/run/mysqld
RUN chown -R mysql:mysql /var/run/mysqld

RUN mkdir -p /var/lib/mysql
RUN chmod 755 /var/lib/mysql
RUN chown -R mysql:mysql /var/lib/mysql

RUN sed -i 's/127.0.0.1/0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

CMD [ "bash" , "./script.sh" ]