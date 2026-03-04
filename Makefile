MYUSER             := $(shell grep MYUSER /home/.secrets.txt | awk '{print $$2}')

SRC = ./srcs/docker-compose.yml

all :
	mkdir -p /home/$(MYUSER)/data/wordpress
	mkdir -p /home/$(MYUSER)/data/mariadb
	docker compose -f ${SRC} build --no-cache
	docker compose -f ${SRC} up -d

ps :
	docker compose -f ${SRC} ps

psa :
	docker compose -f ${SRC} ps -a

logs :
	docker compose -f ${SRC} logs

stop :
	docker compose -f ${SRC} stop

down : stop
	docker compose -f ${SRC} down --volumes

clean : down
	docker builder prune
	docker system  prune --all --volumes

fclean : clean
	sudo rm -rf /home/$(MYUSER)/data

re : clean
	make all

.PHONY : all ps psa logs stop down clean fclean re