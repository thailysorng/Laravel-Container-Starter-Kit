#!/bin/sh
set -e

# Wait for database to be ready (optional but helpful)
# sleep 5 

# Run migrations automatically
php artisan migrate --force

# Execute the container's main command (php-fpm or worker)
exec "$@"
