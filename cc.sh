#!/bin/sh

vagrant ssh -c "cd /var/www && drush cc all"
