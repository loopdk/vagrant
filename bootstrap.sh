#!/usr/bin/env bash

# APT
echo "Updating system (apt)..."
apt-get update > /dev/null 2>&1
apt-get upgrade > /dev/null 2>&1

# Set timezone.
echo "Setting up timezone..."
echo "Europe/Copenhagen" > /etc/timezone
/usr/sbin/dpkg-reconfigure --frontend noninteractive tzdata > /dev/null 2>&1

# Set locale
echo "Setting up locale..."
echo en_GB.UTF-8 UTF-8 > /etc/locale.gen
echo en_DK.UTF-8 UTF-8 >> /etc/locale.gen
echo da_DK.UTF-8 UTF-8 >> /etc/locale.gen
/usr/sbin/locale-gen > /dev/null 2>&1
export LANGUAGE=en_DK.UTF-8 > /dev/null 2>&1
export LC_ALL=en_DK.UTF-8 > /dev/null 2>&1
/usr/sbin/dpkg-reconfigure --frontend noninteractive locales > /dev/null 2>&1

# Drush
echo "Installing drush..."
apt-get install -y php-pear > /dev/null 2>&1
pear channel-discover pear.drush.org > /dev/null 2>&1
pear install drush/drush > /dev/null 2>&1
drush version > /dev/null 2>&1

# Apache config
echo "Configuring Apache..."
apt-get -y install git php5-mysql libapache2-mod-php5 php5-gd php-db apache2 php5-curl php5-dev php5-xdebug > /dev/null 2>&1
rm -rf /var/www
ln -s /vagrant/htdocs /var/www
sed -i '/AllowOverride None/c AllowOverride All' /etc/apache2/sites-available/default
sed -i '/export APACHE_RUN_USER=www-data/c export APACHE_RUN_USER=vagrant' /etc/apache2/envvars
sed -i '/export APACHE_RUN_GROUP=www-data/c export APACHE_RUN_GROUP=vagrant' /etc/apache2/envvars
sed -i '/memory_limit = 128M/c memory_limit = 512M' /etc/php5/apache2/php.ini
chown vagrant:vagrant /var/lock/apache2
a2enmod rewrite > /dev/null 2>&1
a2enmod php5 > /dev/null 2>&1
a2enmod expires > /dev/null 2>&1

# Configura PHP
echo "Configuring up PHP..."
sed -i '/memory_limit = 128M/c memory_limit = 512M' /etc/php5/apache2/php.ini
sed -i '/;date.timezone =/c date.timezone = Europe\/Copenhagen' /etc/php5/apache2/php.ini
sed -i '/;date.timezone =/c date.timezone = Europe\/Copenhagen' /etc/php5/cli/php.ini
sed -i '/upload_max_filesize = 2M/c upload_max_filesize = 16M' /etc/php5/apache2/php.ini
sed -i '/post_max_size = 8M/c post_max_size = 20M' /etc/php5/apache2/php.ini
sed -i '/;realpath_cache_size = 16k/c realpath_cache_size = 256k' /etc/php5/apache2/php.ini

cat << DELIM >> /etc/php5/conf.d/20-xdebug.ini
xdebug.remote_enable=1
xdebug.remote_handler=dbgp
xdebug.remote_host=192.168.50.1
xdebug.remote_port=9000
xdebug.remote_autostart=0
DELIM

pecl install uploadprogress > /dev/null 2>&1
echo "extension=uploadprogress.so" > /etc/php5/conf.d/uploadprogress.ini

# Mysql
echo "Installing MySQL..."
debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password vagrant' > /dev/null 2>&1
debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password vagrant' > /dev/null 2>&1
apt-get install -y mysql-server > /dev/null 2>&1

# Configure MySQL
echo "Configuring MySQL..."
cat > /etc/mysql/conf.d/innodb.cnf <<DELIM
[mysqld]
innodb_buffer_pool_size=256M
innodb_flush_method=O_DIRECT
innodb_additional_mem_pool_size=10M
innodb_flush_log_at_trx_commit=0
innodb_thread_concurrency=6
DELIM

# Memcache
echo "Installing MemCached"
apt-get install -y memcached php5-memcached > /dev/null 2>&1

# APC
echo "Configuring APC"
apt-get install -y php-apc > /dev/null 2>&1
cat > /etc/php5/conf.d/apc.ini <<DELIM
apc.enabled=1
apc.shm_segments=1
apc.optimization=0
apc.shm_size=64M
apc.ttl=7200
apc.user_ttl=7200
apc.num_files_hint=1024
apc.mmap_file_mask=/tmp/apc.XXXXXX
apc.enable_cli=1
apc.cache_by_default=1
DELIM

# Solr
echo "Configuring Solr"
apt-get install -y java7-jdk tomcat7 > /dev/null 2>&1
cd ~
wget http://ftp.download-by.net/apache/lucene/solr/4.7.1/solr-4.7.1.tgz -O solr.tgz > /dev/null 2>&1
tar xzf solr.tgz
rm solr.tgz
cp solr-*/example/lib/ext/* /usr/share/tomcat7/lib/
cp solr-*/dist/solr-*.war /var/lib/tomcat7/webapps/solr.war
cp -R solr-*/example/solr /var/lib/tomcat7
rm -rf solr-*
mv /var/lib/tomcat7/solr/collection1 /var/lib/tomcat7/solr/loop_stg
echo "name=loop_stg" > /var/lib/tomcat7/solr/loop_stg/core.properties

drush dl search_api_solr > /dev/null 2>&1
cp search_api_solr/solr-conf/4.x/* /var/lib/tomcat7/solr/loop_stg/conf/
rm -rf search_api_solr
sed -i '/\<Connector port="8080" protocol="HTTP\/1.1"/c \<Connector port="8983" protocol="HTTP\/1.1"' /var/lib/tomcat7/conf/server.xml
chown -R tomcat7:tomcat7 /var/lib/tomcat7/solr


# Configure Varnish
echo "Installing Varnish..."
wget http://repo.varnish-cache.org/debian/GPG-key.txt > /dev/null 2>&1
apt-key add GPG-key.txt > /dev/null 2>&1
rm GPG-key.txt
echo "deb http://repo.varnish-cache.org/debian/ wheezy varnish-3.0" > /etc/apt/sources.list.d/varnish.list
apt-get update > /dev/null 2>&1
apt-get install varnish -y > /dev/null 2>&1

# Varnish
echo "Configuring varnish..."
apt-get install -y varnish > /dev/null 2>&1
cat > /etc/default/varnish <<DELIM
START=yes
NFILES=131072
MEMLOCK=82000
DAEMON_OPTS="-a :8000 \
             -T localhost:6082 \
             -f /etc/varnish/default.vcl \
             -S /etc/varnish/secret \
             -s malloc,256m"
DELIM

cat > /etc/varnish/default.vcl <<DELIM
backend default {
    .host = "127.0.0.1";
    .port = "80";
}
DELIM

# Restart services
echo "Restarting services..."
service apache2 restart > /dev/null 2>&1
service mysql restart > /dev/null 2>&1
service memcached restart > /dev/null 2>&1
service varnishd restart > /dev/null 2>&1
service tomcat7 restart > /dev/null 2>&1

echo "Provisioning completed..."
