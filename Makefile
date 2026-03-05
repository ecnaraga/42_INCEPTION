MYUSER             := $(shell grep MYUSER /home/.secrets.txt | awk '{print $$2}')
ifeq ($(MYUSER),)
    $(error MYUSER not found in /home/.secrets.txt)
endif

SRC = ./srcs/docker-compose.yml

all :
	mkdir -p /home/$(MYUSER)/data/wordpress
	mkdir -p /home/$(MYUSER)/data/mariadb
	docker compose -f $(SRC) build --no-cache
	docker compose -f $(SRC) up -d

ps :
	docker compose -f $(SRC) ps

psa :
	docker compose -f $(SRC) ps -a

logs :
	docker compose -f $(SRC) logs

stop :
	docker compose -f $(SRC) stop

down : stop
	docker compose -f $(SRC) down

downvolume : stop
	docker compose -f $(SRC) down --volumes
	sudo rm -rf /home/$(MYUSER)/data

clean : down
	docker compose -f $(SRC) down --rmi all
	docker builder prune -f

fclean : downvolume
	docker system  prune --all --volumes

re : clean
	$(MAKE) all

.PHONY : all ps psa logs stop down downvolume clean fclean re