server {
    listen 80;
    listen 443 ssl;
    server_name example.com www.example.com;
    root /var/www/example.com/html;
    ssl_certificate /etc/ssl/certs/example.com.crt;
    ssl_certificate_key /etc/ssl/private/example.com.key;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    
    location / {
    try_files $uri $uri/ =404;
    }
}

