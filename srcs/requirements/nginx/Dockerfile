FROM debian:bullseye

RUN apt update -y
RUN apt upgrade -y
RUN apt install nginx -y
RUN mkdir -p /etc/nginx/ssl
RUN apt install openssl -y
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=galambey.42.fr/UID=galambey"
RUN mkdir -p /var/run/nginx.conf
RUN mkdir -p /var/www/html
RUN chmod 755 /var/www/html
RUN chown -R www-data:www-data /var/www/html

COPY conf/nginx.conf /etc/nginx/nginx.conf

CMD [ "nginx", "-g" , "daemon off;"]
