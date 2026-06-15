#!/bin/sh
set -e

# If we are NOT the main app, wait for the main app to finish setup (vendor folder)
if [ "$1" != "php-fpm" ]; then
    echo "Waiting for setup to complete (vendor/autoload.php)..."
    while [ ! -f vendor/autoload.php ]; do
        sleep 2
    done
fi

# Only run setup if we are starting the main app (php-fpm)
if [ "$1" = "php-fpm" ]; then
    # Create .env if it doesn't exist
    if [ ! -f .env ]; then
        echo "Creating .env file..."
        cp .env.example .env
    fi

    # Install composer dependencies if vendor folder is missing
    if [ ! -d "vendor" ]; then
        echo "Installing composer dependencies..."
        composer install --no-interaction --optimize-autoloader
    fi

    # Generate app key if not set
    if ! grep -q "APP_KEY=base64:" .env || [ -z "$(grep APP_KEY .env | cut -d '=' -f2)" ]; then
        echo "Generating app key..."
        php artisan key:generate --force
    fi

    # Install npm dependencies if node_modules is missing
    if [ ! -d "node_modules" ]; then
        echo "Installing npm dependencies..."
        npm install
    fi

    # Wait for database and run migrations
    echo "Waiting for database..."
    until php artisan db:monitor --databases=mysql > /dev/null 2>&1; do
      echo "Database is unavailable - sleeping"
      sleep 2
    done

    echo "Running migrations..."
    php artisan migrate --force
fi

# Execute the container's main command (php-fpm or worker)
exec "$@"
