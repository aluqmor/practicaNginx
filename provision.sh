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

# PRÁCTICA AUTENTICACIÓN
# Crear un archivo oculto para guardar el usuario y contraseña (nombre)
sudo sh -c "echo -n 'alvaro:' > /etc/nginx/.htpasswd"
sudo sh -c "openssl passwd -apr1 'alvaro' >> /etc/nginx/.htpasswd"

# Crear un archivo oculto para guardar el usuario y contraseña (apellido)
sudo sh -c "echo -n 'luque:' > /etc/nginx/.htpasswd"
sudo sh -c "openssl passwd -apr1 'luque' >> /etc/nginx/.htpasswd"

# Agregar los permisos correspondientes
sudo chown www-data:www-data /etc/nginx/.htpasswd
sudo chmod 640 /etc/nginx/.htpasswd

# Abrir el archivo de configuración del sitio web
sudo nano /etc/nginx/sites-available/perfectlearn

# Crear archivo de configuración del sitio en sites-available
sudo bash -c 'cat > /etc/nginx/sites-available/perfectlearn <<EOF
server {
  listen 80;
  listen [::]:80;
  root /var/www/perfectlearn;
  index index.html index.htm index.php;
  server_name perfectlearn;
  location / {
  auth_basic "Área restringida";
  auth_basic_user_file /etc/nginx/.htpasswd;
  try_files $uri $uri/ =404;
  }
}
EOF'

# Para poder ver la página web en el navegador, debemos modificar el archivo hosts
# También hay que darle los permisos correspondientes
# Creo la nueva carpeta de la pagina web
sudo mkdir -p /var/www/perfectlearn

# Le doy permisos
sudo chown www-data:www-data /var/www/perfectlearn
sudo chmod 775 /var/www/perfectlearn

sudo ln -s /etc/nginx/sites-available/perfectlearn /etc/nginx/sites-enabled/

# Dar permisos de /var/www:
sudo chown -R www-data:www-data /var/www
sudo chmod -R 755 /var/www

# Reiniciar Nginx para aplicar los cambios
sudo systemctl restart nginx

# TAREA 2
# Ahora voy a borrar las dos lineas de location  para hacer que solo haya autenticación para el contact.html
# Para ello vamos a cambiar el directorio raiz de "location /" a "location /contact.html"
# Reiniciar Nginx para aplicar los cambios

# TAREA 3
# Cambiar el location y poner lo siguiente:

# location /api {
#   satisfy all;
#   deny 192.168.1.2;
#   allow 192.168.1.1/24;
#   allow 127.0.0.1;
#   deny all;
#   auth_basic "Administrator's Area";
#   auth_basic_user_file /etc/nginx/.htpasswd;
# }

# PRÁCTICA ACCESO SEGURO
# Crear el archivo para configuración del dominio
sudo nano /etc/nginx/sites-available/example.com

# Agregar archivo de configuracion example.com
sudo cp /vagrant/example.com /etc/nginx/sites-available/example.com

# Crear enlace simbolico
sudo ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/

# Recargar servidor
sudo systemctl reload nginx

# Instalar el cortafuegos
sudo apt install ufw

# Activar el tráfico HTTPS
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw delete allow 'Nginx HTTP'

# Activar el cortafuegos
sudo ufw --force enable

# Generar certificado autofirmado
sudo openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 -keyout /etc/ssl/private/example.com.key \
  -out /etc/ssl/certs/example.com.crt

# Añadir uso de certificado SSL
sudo cp /vagrant/example.com /etc/nginx/sites-available/example.com

# Recargar servidor
sudo systemctl reload nginx
