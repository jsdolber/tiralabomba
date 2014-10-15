#!/bin/sh
cd /var/www/tiralabomba.com/public_html/
padrino runner -e production runners/remove_unpub.rb