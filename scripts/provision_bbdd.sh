#!/bin/bash
set -x

# 1. Instalar MariaDB, Git y UFW
apt-get update
apt-get install -y mariadb-server git ufw

# 2. Permitir conexiones externas en MariaDB
sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mysql/mariadb.conf.d/50-server.cnf
systemctl restart mariadb

# 3. Clonar repositorio e importar base de datos
rm -rf /tmp/iaw-practica-lamp
git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /tmp/iaw-practica-lamp
mysql -u root < /tmp/iaw-practica-lamp/db/database.sql

# 4. Crear usuario con acceso exclusivo para Web1 y Web2
mysql -u root -e "DROP USER IF EXISTS 'lamp_user'@'192.168.57.11';"
mysql -u root -e "CREATE USER 'lamp_user'@'192.168.57.11' IDENTIFIED BY 'amparo1234@';"
mysql -u root -e "GRANT ALL PRIVILEGES ON lamp_db.* TO 'lamp_user'@'192.168.57.11';"

mysql -u root -e "DROP USER IF EXISTS 'lamp_user'@'192.168.57.12';"
mysql -u root -e "CREATE USER 'lamp_user'@'192.168.57.12' IDENTIFIED BY 'amparo1234@';"
mysql -u root -e "GRANT ALL PRIVILEGES ON lamp_db.* TO 'lamp_user'@'192.168.57.12';"
mysql -u root -e "FLUSH PRIVILEGES;"

# 5. Configurar cortafuegos (Solo puerto 3306 para las webs)
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow from 192.168.57.11 to any port 3306 proto tcp
ufw allow from 192.168.57.12 to any port 3306 proto tcp
ufw --force enable

# 6. Aislar la máquina de Internet
ip route del default