# Stop services
sudo systemctl stop apache2 && sudo systemctl stop mysql

# Remove Nextcloud files
sudo rm -rf /var/www/html/nextcloud /var/www/html/nextcloud/data

# Drop database and user
sudo mysql -u root -p -e "DROP DATABASE nextcloud; DROP USER 'nextclouduser'@'localhost'; FLUSH PRIVILEGES;"

# Remove Apache configuration
sudo a2dissite nextcloud && sudo rm /etc/apache2/sites-available/nextcloud.conf && sudo systemctl reload apache2

# Remove PHP and other dependencies (optional)
sudo apt remove --purge -y php8.1 php8.1-xml php8.1-mbstring php8.1-curl php8.1-zip php8.1-gd php8.1-mysql && sudo apt autoremove -y

# Remove MySQL (optional)
sudo apt remove --purge -y mysql-server mysql-client mysql-common mysql-server-core-* mysql-client-core-* && sudo apt autoremove -y && sudo apt autoclean

# Clean up residual files (optional)
sudo rm -rf /etc/mysql /var/lib/mysql /var/log/mysql

# Restart services (if needed)
sudo systemctl start apache2 && sudo systemctl start mysql
