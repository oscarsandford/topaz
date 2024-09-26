#!/bin/bash

set -e

POSTGRES_USER=$(cat /run/secrets/postgres_user)
POSTGRES_PASSWORD=$(cat /run/secrets/postgres_password)
PGPOOL_PASSWORD=$(cat /run/secrets/pgpool_password)
REPLICATION_PASSWORD=$(cat /run/secrets/replication_password)
READER_PASSWORD=$(cat /run/secrets/reader_password)
WRITER_PASSWORD=$(cat /run/secrets/writer_password)

echo "Running init-primary.sh"

echo "Copying configuration files from /etc/postgres to /var/lib/postgresql/data"
cp /etc/postgresql/postgresql.conf /var/lib/postgresql/data/postgresql.conf
cp /etc/postgresql/pg_hba.conf /var/lib/postgresql/data/pg_hba.conf
echo "Reloading configuration files"
pg_ctl reload

echo "Creating objects"
PGPASSWORD="$POSTGRES_PASSWORD" psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE topaz;
EOSQL

# Also consider CREATE ROLE pgpool_user NOSUPERUSER NOINHERIT NOCREATEDB NOCREATEROLE NOLOGIN; instead of CREATE USER.
PGPASSWORD="$POSTGRES_PASSWORD" psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE USER pgpool_user WITH ENCRYPTED PASSWORD '$PGPOOL_PASSWORD';
    GRANT CONNECT ON DATABASE topaz TO pgpool_user;
    GRANT SELECT ON pg_stat_replication TO pgpool_user;
EOSQL

PGPASSWORD="$POSTGRES_PASSWORD" psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE USER replication_user REPLICATION LOGIN CONNECTION LIMIT 10 ENCRYPTED PASSWORD '$REPLICATION_PASSWORD';
    GRANT CONNECT ON DATABASE topaz TO replication_user;
EOSQL

PGPASSWORD="$POSTGRES_PASSWORD" psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE ROLE reader WITH ENCRYPTED PASSWORD '$READER_PASSWORD' LOGIN;
    GRANT CONNECT ON DATABASE topaz TO reader;
    CREATE ROLE writer WITH ENCRYPTED PASSWORD '$WRITER_PASSWORD' LOGIN;
    GRANT CONNECT ON DATABASE topaz TO writer;
EOSQL

# Commands are run on the given database
PGPASSWORD="$POSTGRES_PASSWORD" psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d topaz <<-EOSQL
    CREATE SCHEMA imdb;
    GRANT USAGE ON SCHEMA imdb TO writer;
    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA imdb TO writer;
    ALTER DEFAULT PRIVILEGES IN SCHEMA imdb GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO writer;
    GRANT USAGE ON SCHEMA imdb TO reader;
    GRANT SELECT ON ALL TABLES IN SCHEMA imdb TO reader;
    ALTER DEFAULT PRIVILEGES IN SCHEMA imdb GRANT SELECT ON TABLES TO reader;
EOSQL

echo "Done init-primary.sh"
