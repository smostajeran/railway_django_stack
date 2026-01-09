#!/bin/sh
set -e

echo "Collecting static files.."
python manage.py collectstatic --noinput

if [ "$RUN_MIGRATIONS" = "True" ]; then
    echo "Running migrations..."
    until python manage.py migrate
    do
        echo "Waiting for db to be ready..."
        sleep 2
    done
fi

PORT=${PORT:-8000}

echo "Starting app server on PORT=$PORT ..."
python -m gunicorn railway_django_stack.wsgi:application \
    --bind 0.0.0.0:$PORT \
    --log-level info \
    --config python:deployment.gunicorn_config \
    --forwarded-allow-ips "*"
