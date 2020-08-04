#!/bin/sh
set -e


# Update permissions
chown -R www-data:www-data .
sync

# Start Apache with the right permissions
/var/www/html/iwacs/docker/apache/start-safe-perms.sh -DFOREGROUND
