#!/bin/bash
set -x

# 1. Instalar Apache, PHP, conector MySQL, Git y UFW
apt-get update
apt-get install -y apache2 php libapache2-mod-php php-mysql git ufw

# 2. Clonar la aplicación web y moverla al directorio raíz de Apache
rm -rf /tmp/iaw-practica-lamp
git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /tmp/iaw-practica-lamp
rm -rf /var/www/html/*
cp -r /tmp/iaw-practica-lamp/src/* /var/www/html/

# 3. Configurar config.php para conectar con la Base de Datos de la Capa 3 (192.168.57.20)
sed -i "s/localhost/192.168.57.20/g" /var/www/html/config.php
sed -i "s/database_name_here/lamp_db/g" /var/www/html/config.php
sed -i "s/username_here/lamp_user/g" /var/www/html/config.php
sed -i "s/password_here/amparo1234@/g" /var/www/html/config.php

# 4. Identificar el servidor web en la portada para comprobar el balanceo de carga
sed -i "s/Simple LAMP web app/Simple LAMP web app - Atendido por: $(hostname)/g" /var/www/html/index.php

# 5. Ajustar permisos y reiniciar Apache
chown -R www-data:www-data /var/www/html
systemctl restart apache2

# 6. Configurar cortafuegos (Solo permite tráfico HTTP desde el Balanceador)
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow from 192.168.56.10 to any port 80 proto tcp
ufw --force enable

# 7. Aislar la máquina de Internet (Simulando Subred Privada)
ip route del default