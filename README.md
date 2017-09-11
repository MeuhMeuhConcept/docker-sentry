# docker-sentry
Sentry configuration

## Installation
Create env files
```
make install
```
Edit following files to configure your sentry platform :
* postfix.env
* postgresql.env
* sentry.env
* sentry.port
* docker-composer.yml

## Launch containers
```
make start
```

## Upgrade your database
In the first launch
```
make sentry-upgrade
```

## Create user (if not already done in previous step)
```
make sentry-user
```

## Bonus

### View commands list
```
make
```
