#!/bin/sh
importer_path=`/var/www/tiralabomba.com/public_html/padrino runner -e production /var/www/tiralabomba.com/public_html/runners/import_tweets.rb`
eval importer_path