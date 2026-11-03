#!/bin/bash
set -x

# 1. Instalar Apache, OpenSSL, Certbot y UFW
apt-get update
apt-get install -y apache2 openssl certbot python3-certbot-apache ufw

# 2. Activar módulos de Proxy Inverso, Balanceador (Round Robin) y SSL
a2enmod proxy
a2enmod proxy_http
a2enmod proxy_balancer
a2enmod lbmethod_byrequests
a2enmod ssl
a2enmod headers
a2enmod rewrite

# 3. Generar certificado SSL autofirmado para pruebas HTTPS en entorno local
mkdir -p /etc/apache2/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/apache2/ssl/balanceador.key \
  -out /etc/apache2/ssl/balanceador.crt \
  -subj "/C=ES/ST=Badajoz/L=Merida/O=IESAlbarregas/OU=ASIR/CN=amparosanchez.ddns.net"

# 4. Crear el archivo de configuración del Balanceador (HTTP y HTTPS)
cat <<EOF > /etc/apache2/sites-available/load-balancer.conf
<VirtualHost *:80>
    ServerName amparosanchez.ddns.net

    <Proxy balancer://mycluster>
        # Servidor Web 1
        BalancerMember http://192.168.56.11
        # Servidor Web 2
        BalancerMember http://192.168.56.12
    </Proxy>

    ProxyPass / balancer://mycluster/
    ProxyPassReverse / balancer://mycluster/
</VirtualHost>

<VirtualHost *:443>
    ServerName amparosanchez.ddns.net

    SSLEngine on
    SSLCertificateFile /etc/apache2/ssl/balanceador.crt
    SSLCertificateKeyFile /etc/apache2/ssl/balanceador.key

    <Proxy balancer://mycluster>
        # Servidor Web 1
        BalancerMember http://192.168.56.11
        # Servidor Web 2
        BalancerMember http://192.168.56.12
    </Proxy>

    ProxyPass / balancer://mycluster/
    ProxyPassReverse / balancer://mycluster/
</VirtualHost>
EOF

# 5. Habilitar el balanceador y desactivar el sitio por defecto
a2ensite load-balancer.conf
a2dissite 000-default.conf
systemctl restart apache2

# (Opcional en red pública / AWS) Solicitud de certificado con Certbot y Let's Encrypt:
# certbot --apache -m correo@dominio.es --agree-tos --no-eff-email -d amparosanchez.ddns.net --non-interactive

# 6. Configurar cortafuegos (Puertos públicos 22, 80 y 443)
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable