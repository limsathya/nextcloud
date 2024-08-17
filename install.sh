#!/bin/bash

# Set variables
DOMAIN="your_domain"
DB_PASSWORD="your_password"
ADMIN_PASSWORD="your_admin_password"

# Check if the script is running as root
if [ "$(id -u)" -ne "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Check and install required packages
REQUIRED_PKG="apache2 mysql-server php libapache2-mod-php php-mysql php-xml php-mbstring php-curl php-zip php-gd unzip wget curl"
for PKG in $REQUIRED_PKG; do
    if ! dpkg -l | grep -qw "$PKG"; then
        echo "$PKG is not installed. Installing..."
        apt-get install -y "$PKG"
    else
        echo "$PKG is already installed."
    fi
done

# Secure MySQL installation and create database
echo "Securing MySQL and creating database..."
mysql -e "UPDATE mysql.user SET authentication_string=null WHERE User='root';"
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DB_PASSWORD';"
mysql -e "FLUSH PRIVILEGES;"
mysql -e "CREATE DATABASE nextcloud;"
mysql -e "CREATE USER 'nextclouduser'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
mysql -e "GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextclouduser'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Download and install Nextcloud
echo "Downloading and installing Nextcloud..."
wget https://download.nextcloud.com/server/releases/nextcloud-25.0.2.zip
unzip nextcloud-25.0.2.zip
mv nextcloud /var/www/html/
chown -R www-data:www-data /var/www/html/nextcloud
chmod -R 755 /var/www/html/nextcloud

# Configure Apache
echo "Configuring Apache..."
cat > /etc/apache2/sites-available/nextcloud.conf <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@$DOMAIN
    DocumentRoot /var/www/html/nextcloud
    ServerName $DOMAIN

    <Directory /var/www/html/nextcloud/>
        AllowOverride All
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

a2ensite nextcloud
a2enmod rewrite
a2enmod headers
systemctl restart apache2

# Install Nextcloud via command line
echo "Installing Nextcloud..."
sudo -u www-data php /var/www/html/nextcloud/occ maintenance:install --database "mysql" --database-name "nextcloud" --database-user "nextclouduser" --database-pass "$DB_PASSWORD" --admin-user "admin" --admin-pass "$ADMIN_PASSWORD"

echo "Nextcloud installation complete. Visit http://$DOMAIN to complete the setup through the web interface."
