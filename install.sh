#!/bin/bash

# Nextcloud Automated Installation Script for Ubuntu

# Function to prompt for the domain
read -p "Enter your domain (e.g., example.com) or use IP for local access: " DOMAIN

# Update and upgrade the system
echo "Updating and upgrading system packages..."
sudo apt update && sudo apt upgrade -y

# Install Apache, PHP, and modules
echo "Installing Apache and PHP modules..."
sudo apt install apache2 libapache2-mod-php php-mysql php-xml php-gd php-curl php-zip php-mbstring php-intl php-bcmath php-gmp wget unzip -y

# Install MariaDB
echo "Installing MariaDB..."
sudo apt install mariadb-server -y
sudo mysql_secure_installation

# Set up MariaDB for Nextcloud
echo "Configuring MariaDB..."
sudo mysql -u root -p <<MYSQL_SCRIPT
CREATE DATABASE nextcloud;
CREATE USER 'nextclouduser'@'localhost' IDENTIFIED BY 'yourpassword';
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextclouduser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
MYSQL_SCRIPT

# Download and install Nextcloud
echo "Downloading and installing Nextcloud..."
wget https://download.nextcloud.com/server/releases/latest.zip
unzip latest.zip
sudo mv nextcloud /var/www/
sudo chown -R www-data:www-data /var/www/nextcloud
sudo chmod -R 755 /var/www/nextcloud

# Create Apache configuration for Nextcloud
echo "Configuring Apache for Nextcloud..."
sudo bash -c "cat > /etc/apache2/sites-available/nextcloud.conf <<EOF
<VirtualHost *:80>
    DocumentRoot /var/www/nextcloud/
    ServerName $DOMAIN

    <Directory /var/www/nextcloud/>
        Require all granted
        AllowOverride All
        Options FollowSymLinks MultiViews

        <IfModule mod_dav.c>
            Dav off
        </IfModule>
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/nextcloud_error.log
    CustomLog \${APACHE_LOG_DIR}/nextcloud_access.log combined
</VirtualHost>
EOF"

# Enable the site and Apache modules
sudo a2ensite nextcloud.conf
sudo a2enmod rewrite headers env dir mime
sudo systemctl restart apache2

# Optional: Set up SSL with Let's Encrypt
read -p "Would you like to set up SSL using Let's Encrypt? (y/n): " ssl_choice
if [ "$ssl_choice" = "y" ]; then
  sudo apt install certbot python3-certbot-apache -y
  sudo certbot --apache -d $DOMAIN
fi

echo "Installation completed! You can now access Nextcloud at http://$DOMAIN"
