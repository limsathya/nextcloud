#!/bin/bash

# Define domain variable (default example.com)
DOMAIN="example.com"

# Function to display usage information
usage() {
    echo "Usage: $0 -d <domain>"
    echo "Example: $0 -d mycloud.example.com"
    exit 1
}

# Parse command line options
while getopts ":d:" opt; do
    case ${opt} in
        d)
            DOMAIN=${OPTARG}
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            ;;
    esac
done

# Install required packages
sudo apt update
sudo apt install -y apache2 mariadb-server libapache2-mod-php7.4 \
    php7.4-gd php7.4-json php7.4-mysql php7.4-curl php7.4-mbstring \
    php7.4-intl php7.4-imagick php7.4-xml php7.4-zip

# Configure MariaDB
sudo mysql -u root -p -e "CREATE DATABASE nextcloud;"
sudo mysql -u root -p -e "CREATE USER 'nextclouduser'@'localhost' IDENTIFIED BY 'your_password';"
sudo mysql -u root -p -e "GRANT ALL ON nextcloud.* TO 'nextclouduser'@'localhost';"
sudo mysql -u root -p -e "FLUSH PRIVILEGES;"

# Install Nextcloud
wget https://download.nextcloud.com/server/releases/latest.tar.bz2
sudo tar -xjf latest.tar.bz2 -C /var/www/
sudo chown -R www-data:www-data /var/www/nextcloud/

# Configure Apache
sudo tee /etc/apache2/sites-available/nextcloud.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerAdmin admin@$DOMAIN
    DocumentRoot /var/www/nextcloud/
    ServerName $DOMAIN

    <Directory /var/www/nextcloud/>
        Options +FollowSymlinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

sudo a2ensite nextcloud.conf
sudo a2enmod rewrite headers env dir mime
sudo systemctl restart apache2

# Set up SSL with Let's Encrypt
sudo apt install certbot python3-certbot-apache
sudo certbot --apache -d $DOMAIN
