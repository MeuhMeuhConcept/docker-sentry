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

## Launch dependencies containers
```
make redis postgresql postfix
```

## Upgrade your database
```
make sentry-upgrade
```

## Create user (if noo already done in previous step)
```
make sentry-user
```

## Launch sentry containers
```
make sentry sentry-cron sentry-worker
```

## Bonus

### View commands list
```
make
```
