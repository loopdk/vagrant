#!/usr/bin/env bash

# Drush
echo "Installing drush"
apt-get install -y php-pear > /dev/null 2>&1

pear channel-discover pear.drush.org > /dev/null 2>&1
pear install drush/drush > /dev/null 2>&1

drush version > /dev/null 2>&1

# Apache config
echo "Configuing apache"
apt-get -y install php5-mysql libapache2-mod-php5 php5-gd php-db apache2 lsyncd php5-curl > /dev/null 2>&1

rm -rf /var/www
ln -s /vagrant/htdocs /var/www

sed -i '/AllowOverride None/c AllowOverride All' /etc/apache2/sites-available/default
sed -i '/export APACHE_RUN_USER=www-data/c export APACHE_RUN_USER=vagrant' /etc/apache2/envvars
sed -i '/export APACHE_RUN_GROUP=www-data/c export APACHE_RUN_GROUP=vagrant' /etc/apache2/envvars
sed -i '/memory_limit = 128M/c memory_limit = 512M' /etc/php5/apache2/php.ini
chown vagrant:vagrant /var/lock/apache2

a2enmod rewrite > /dev/null 2>&1

a2enmod php5 > /dev/null 2>&1

# Mysql
echo "Configuring mysql"

debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password vagrant' > /dev/null 2>&1
debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password vagrant' > /dev/null 2>&1

apt-get install -y mysql-server > /dev/null 2>&1

echo "Starting mysql"

# Memcache
echo "Install memcache"

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

wget http://ftp.download-by.net/apache/lucene/solr/4.7.0/solr-4.7.0.tgz -O solr.tgz > /dev/null 2>&1

tar xzf solr.tgz
rm solr.tgz

cp solr-4.7.0/example/lib/ext/* /usr/share/tomcat7/lib/

cp solr-4.7.0/dist/solr-4.7.0.war /var/lib/tomcat7/webapps/solr.war

cp -R solr-4.7.0/example/solr /var/lib/tomcat7

rm -rf solr-4.7.0

mv /var/lib/tomcat7/solr/collection1 /var/lib/tomcat7/solr/loop_stg

echo "name=loop_stg" > /var/lib/tomcat7/solr/loop_stg/core.properties

drush dl search_api_solr
cp search_api_solr/solr-conf/4.x/* /var/lib/tomcat7/solr/loop_stg/conf/

rm -rf search_api_solr

sed -i '/\<Connector port="8080" protocol="HTTP\/1.1"/c \<Connector port="8983" protocol="HTTP\/1.1"' /var/lib/tomcat7/conf/server.xml

chown -R tomcat7:tomcat7 /var/lib/tomcat7/solr

service tomcat7 restart

# Varnish
echo "Configuring varnish"

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

echo "Starting apache"
service apache2 restart > /dev/null 2>&1

echo "Starting varnish"
service varnish restart > /dev/null 2>&1

echo "Done"
