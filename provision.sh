#!/bin/bash

# 1. Actualizar repositorios, instalar Nginx, instalar git para traer el repositorio
apt update
apt install -y nginx git vsftpd

# Verificar que Nginx esté funcionando
sudo systemctl status nginx

# 2. Crear la carpeta del sitio web
sudo mkdir -p /var/www/paginaweb/html

# Clonar el repositorio de ejemplo en la carpeta del sitio web
git clone https://github.com/cloudacademy/static-website-example /var/www/paginaweb/html

# Asignar permisos adecuados
sudo chown -R www-data:www-data /var/www/paginaweb/html
sudo chmod -R 755 /var/www/paginaweb

# 3. Configurar Nginx para servir el sitio web
# Crear archivo de configuración del sitio en sites-available
sudo bash -c 'cat > /etc/nginx/sites-available/paginaweb <<EOF
server {
    listen 80;
    listen [::]:80;
    root /var/www/paginaweb/html;
    index index.html index.htm index.nginx-debian.html;
    server_name www.alvaro.test;
    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF'

# Crear enlace simbólico en sites-enabled
sudo ln -s /etc/nginx/sites-available/paginaweb /etc/nginx/sites-enabled/

# ASEGURATE DE CAMBIAR EL ARCHIVO vsftpd.conf Y DEJARLO COMO EL QUE TENGO EN EL DIRECTORIO

# Crear usuario
sudo adduser alvaro
echo "alvaro:alvaro" | sudo chpasswd

# Crea la carpeta (aunque deberia estar creada al crear el usuario)
sudo mkdir /home/alvaro/ftp

# Permisos para la carpeta
sudo chown vagrant:vagrant /home/alvaro/ftp
sudo chmod 755 /home/alvaro/ftp

# Crear los certificados de seguridad
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.key -out /etc/ssl/certs/vsftpd.crt

# Agregar el usuario alvaro al grupo www-data
sudo usermod -aG www-data alvaro

# Creo la nueva carpeta de la pagina web
sudo mkdir -p /var/www/bluehorizon

# Le doy permisos
sudo chown www-data:www-data /var/www/bluehorizon
sudo chmod 775 /var/www/bluehorizon

sudo ln -s /etc/nginx/sites-available/bluehorizon /etc/nginx/sites-enabled/

# Reiniciar Nginx para aplicar los cambios
sudo systemctl restart nginx
# Si da un error de 404 FORFBIDDEN ejecutar el siguiente comando