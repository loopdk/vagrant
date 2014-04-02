# LOOP Vagrant setup

## Vagrant setup
Install Vagrant from [http://www.vagrantup.com/downloads.html](http://www.vagrantup.com/downloads.html)

## Vagrant add-ons
`vagrant plugin install vagrant-hostsupdater`

## First time
Make a folder named htdocs
ie `drush make --working-copy https://raw.github.com/loopdk/profile/development/drupal.make htdocs`

Create a database for loop.

## Simple control of Vagrant
### To start
`vagrant up`

### To stop
`vagrant halt`

### To delete
`vagrant destroy`

## Information
Apache is avavible from [http://loop.local](http://loop.local)

Varnish from [http://loop.local:8000](http://loop.local:8000)

Solr [http://loop.local:8983/solr](http://http://loop.local:8983/solr)

Default mySQL password is 'vagrant'.
