sudo rm -rf /var/www/html/nextcloud /var/www/html/nextcloud/data && \
sudo mysql -u root -p -e "DROP DATABASE nextcloud; DROP USER 'nextclouduser'@'localhost'; FLUSH PRIVILEGES;" && \
sudo a2dissite nextcloud && \
sudo rm /etc/apache2/sites-available/nextcloud.conf && \
sudo systemctl reload apache2 && \
sudo apt remove --purge -y php8.1 php8.1-xml php8.1-mbstring php8.1-curl php8.1-zip php8.1-gd php8.1-mysql && \
sudo apt autoremove -y
