#!bin/bash

# Pour debug
set -x

# A garder si pb au moment de passer sur la vm et que les tables n existe pas
# mysql_install_db --user=root --datadir=/var/lib/mysql

# Lance le service mariadb pour pouvoir executer les cmd mysql
service mariadb start

until mysql -u root -e "SELECT 1" > /dev/null 2>&1; do
    echo "Waiting for MariaDB to be ready..."
    sleep 1
done

# Il faut passer par my sql -e qui permet d executer une requete sql dans la base de donnees via le terminal 
#   et donc d expand les variables d environnement avant d exec la requete car Mariadb ne le fait pas.
# Normalement toutes les commandes executees avec mysql (qui necessite donc un db_client ) peuvent etre executee directement par le db_server avec mysqladmin => a verifier

# Attribue un mot de passe a root
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}'";
# mysql -u root -p${DB_ROOT_PASSWORD} -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}'";

# Cree la database wordpress
mysql -u root -p${DB_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS ${MARIADB_DATABASE}";

# Cree le user wordpress et lui attribue un mot de passe
mysql -u root -p${DB_ROOT_PASSWORD} -e "CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}'";

# Donne au user wordpress les privilege sur la base de donnees wordpress
mysql -u root -p${DB_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON ${MARIADB_DATABASE}.* TO '${MARIADB_USER}'@'%'";

# Enregistre les changements de privileges
mysql -u root -p${DB_ROOT_PASSWORD} -e "FLUSH PRIVILEGES";

# shutdown mariadb pour le lancer avec mysqld
mysqladmin -u root -p${DB_ROOT_PASSWORD} shutdown

# Lancer avec exec et non via la ligne de command sinon pb car :
#   exec va remplacer le process en cours dans le service mariadb par le process my_sqld
#   ainsi wordpress pourra se connecter quand il veut a la database et envoyer des requetes sql directement
exec mysqld_safe

# Tout ce qu on pourrait mettre ici ne s executerai pas car le process a ete remplace et le script ne se terminera donc jamais