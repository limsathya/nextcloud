# Set up variables
DOMAIN="yourdomain.com"
ADMIN_EMAIL="webmaster@yourdomain.com"
CERT_PATH="/etc/ssl/certs/nextcloud-selfsigned.crt"
KEY_PATH="/etc/ssl/private/nextcloud-selfsigned.key"
APACHE_CONF="/etc/apache2/sites-available/nextcloud-ssl.conf"

# Generate the self-signed SSL certificate
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $KEY_PATH -out $CERT_PATH -subj "/C=US/ST=State/L=City/O=Organization/OU=Department/CN=$DOMAIN/emailAddress=$ADMIN_EMAIL"

# Create the SSL VirtualHost configuration
sudo bash -c "cat > $APACHE_CONF" <<EOL
<IfModule mod_ssl.c>
<VirtualHost *:443>
    ServerAdmin $ADMIN_EMAIL
    DocumentRoot /var/www/nextcloud
    ServerName $DOMAIN

    <Directory /var/www/nextcloud>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    SSLEngine on
    SSLCertificateFile $CERT_PATH
    SSLCertificateKeyFile $KEY_PATH

    ErrorLog \${APACHE_LOG_DIR}/nextcloud_ssl_error.log
    CustomLog \${APACHE_LOG_DIR}/nextcloud_ssl_access.log combined

    <FilesMatch "\.(cgi|shtml|phtml|php)$">
        SSLOptions +StdEnvVars
    </FilesMatch>
    <Directory "/usr/lib/cgi-bin">
        SSLOptions +StdEnvVars
    </Directory>

    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
</VirtualHost>
</IfModule>
EOL

# Create the HTTP-to-HTTPS redirect configuration
sudo bash -c "cat > /etc/apache2/sites-available/nextcloud.conf" <<EOL
<VirtualHost *:80>
    ServerAdmin $ADMIN_EMAIL
    DocumentRoot /var/www/nextcloud
    ServerName $DOMAIN

    Redirect permanent / https://$DOMAIN/
</VirtualHost>
EOL

# Enable the SSL site and necessary modules
sudo a2ensite nextcloud-ssl.conf
sudo a2enmod ssl
sudo a2enmod headers

# Disable the default Apache site (optional)
sudo a2dissite 000-default.conf

# Reload Apache to apply changes
sudo systemctl restart apache2
