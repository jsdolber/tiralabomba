#!/bin/sh
cd /var/www/tiralabomba.com/public_html/
padrino runner -e production runners/import_tweets.rb