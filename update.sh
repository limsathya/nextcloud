# Backup
sudo tar -czvf nextcloud-data-backup.tar.gz /var/www/html/nextcloud/data
mysqldump -u root -p nextcloud > nextcloud-database-backup.sql

# Maintenance Mode
sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --on

# Update
wget https://download.nextcloud.com/server/releases/nextcloud-latest.zip
unzip nextcloud-latest.zip
sudo rsync -av --delete nextcloud/ /var/www/html/nextcloud/
sudo chown -R www-data:www-data /var/www/html/nextcloud
sudo chmod -R 755 /var/www/html/nextcloud

# Upgrade
sudo -u www-data php /var/www/html/nextcloud/occ upgrade

# Maintenance Mode Off
sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --off

# Optional Cache Clear
sudo -u www-data php /var/www/html/nextcloud/occ maintenance:repair
