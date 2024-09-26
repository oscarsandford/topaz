# Topaz

A Postgres configuration I'm working on. One primary database, two replicas, and a PgPool proxy to manage connections.

## Architecture

I will describe it in detail here.

## Configuration

Additonal secrets in various directories need to be created.

### `secrets/`

Several more password files should be included in a the directory `secrets/`.
- `secrets/postgres_password`
- `secrets/replication_password`
- `secrets/pgpool_password`
- `secrets/reader_password`
- `secrets/writer_password`
- `secrets/pgpool_pcp_password`
- `secrets/.pgpoolkey`

The contents of these can be random strings. Lastly, the file `secrets/postgres_user` should simply contain the string `postgres`.

### `pgpool/pcp.conf`

The file `pgpool/pcp.conf` contains a username and MD5-hashed password for running PCP commands on the PgPool container (note that this is not a Postgres user). Each line is a username and password in the following format:
```
username:md5hash
```
In this configuration of PgPool, the username is assumed to be `pcp_user`, but you can configure it however you like. You can create a hash of the password by running the following in an environment with PgPool installed (e.g. the PgPool container):
```sh
pd_md5 user_password
```
and copy the output to replace `md5hash` in `pcp.conf`.

Note that the location of PgPool configuration files in the installation (e.g. container) may be different than in this repository.

### `pgpool/pool_passwd`

The file `pgpool/pool_passwd` contains usernames and passwords for Postgres users that can [authenticate through PgPool](https://www.pgpool.net/docs/latest/en/html/auth-aes-encrypted-password.html). The passwords should be encrypted, and you can store them as either plain text, MD5-hashed text, or AES-encrypted text. This configuration uses `scram-sha-256`, so we must [encrypt them](https://www.pgpool.net/docs/latest/en/html/pg-enc.html) using the key in `secrets/.pgpoolkey`.

The following command will encrypt the given plain text `user_password` using AES256 with the key in `secrets/.pgpoolkey`, and then append the username and AES-encrypted password to `pgpool/pool_passwd`.
```sh
pg_enc -m -u username user_password
```
Remember that the username should be the name of the user in Postgres, and the password provided should be the same as the password of the user in Postgres. You can use `-p` to prompt for the password instead of providing it on the same line.

Also remember to `chmod 0600 .pgpoolkey` to avoid any warnings. Note that the location of PgPool configuration files in the installation (e.g. container) may be different than in this repository.

## Deployment

If everything is set up properly, you should be able to simply
```sh
docker compose up
```

An additional container is provided to help test connections to the DBMS. You may `exec` into it in order to use `psql`.

If you wish to connect to the DBMS from other computers, you should configure your system accordingly.
