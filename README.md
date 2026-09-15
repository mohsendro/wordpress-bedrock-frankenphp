# WordPress Bedrock + Docker + FrankenPHP Starter

A reusable production-oriented WordPress starter built around Bedrock, Composer/WP Packages, Docker, MySQL 8.4, Redis, WP-CLI and FrankenPHP.

The important design decision is that **FrankenPHP is a runtime choice, not a hard dependency of the project**. The same repository can run with FrankenPHP or with PHP-FPM + Nginx.

## Stack

- WordPress + Bedrock
- Composer / WP Packages
- Docker Compose
- MySQL 8.4
- Redis 7
- WP-CLI
- FrankenPHP, optionally enabled
- PHP-FPM + Nginx fallback
- Mailpit for local email testing
- GitHub Actions + GHCR

## 1. Start a new project

Clone/download the starter and run:

```bash
cp .env.example .env
make bootstrap
```

Bootstrap creates `.env`, resolves dependencies on first run, creates `composer.lock` when needed, builds the selected runtime and waits for the services.

Commit `composer.lock` after the first successful dependency resolution. Once it exists, deployments use the locked dependency set instead of resolving arbitrary new versions.

## 2. FrankenPHP on/off

### Enabled

```dotenv
FRANKENPHP_ENABLED=true
FRANKENPHP_MODE=classic
```

Then:

```bash
make up
```

The web runtime is FrankenPHP.

### Disabled

```dotenv
FRANKENPHP_ENABLED=false
```

Then:

```bash
make up
```

The runtime becomes:

```text
Nginx -> PHP-FPM -> WordPress
```

FrankenPHP is not used to serve requests.

### Worker mode

Worker mode is available but intentionally opt-in:

```dotenv
FRANKENPHP_ENABLED=true
FRANKENPHP_MODE=worker
```

FrankenPHP worker mode keeps the application bootstrapped in memory. WordPress plugins/themes should be tested for long-lived worker compatibility before using this mode in production.

## 3. Local services

```text
MySQL 8.4
Redis 7
Mailpit
Web runtime
```

Mailpit: `http://localhost:8025`

WordPress: `http://localhost`

## 4. Composer and WordPress packages

Normal PHP package:

```bash
composer require vendor/package
```

A package available through WP Packages can be installed with Composer, for example:

```bash
composer require wp-plugin/plugin-name
```

Commit both `composer.json` and `composer.lock`. Never commit `vendor/`.

## 5. Development workflow

```text
Starter
  ↓
.env
  ↓
make bootstrap
  ↓
Composer dependencies
  ↓
Docker
  ↓
Local development
  ↓
Git commit
  ↓
Git push
```

Useful commands:

```bash
make bootstrap
make up
make down
make logs
make shell
make wp
make composer
make backup
make health
```

## 6. Production architecture

Every production commit can produce two immutable images:

```text
GitHub
  ├── FrankenPHP
  │   ghcr.io/mohsendro/wordpress-bedrock-frankenphp:<commit-sha>
  │
  └── PHP-FPM
      ghcr.io/mohsendro/wordpress-bedrock-php-fpm:<commit-sha>
```

The production server chooses the runtime from its own `.env`:

```dotenv
FRANKENPHP_ENABLED=true
```

or:

```dotenv
FRANKENPHP_ENABLED=false
```

The server does not build application images. GitHub Actions builds and publishes them; the server pulls the exact image identified by the commit SHA.

## 7. Production server and zero-touch provisioning

The GitHub Actions deployment can provision a fresh Debian/Ubuntu server automatically. It installs Docker Engine, Buildx and the Compose plugin, creates the application directory, authenticates to GHCR, pulls the exact images and starts the stack.

Docker is installed from Docker's official apt repository rather than the distribution's unofficial Docker packages.

The application directory is:

```text
/srv/apps/wordpress-bedrock-frankenphp/
```

The only external prerequisites are:

- A Debian/Ubuntu server reachable over SSH
- An SSH user with `sudo` privileges
- DNS pointing the domain to the server
- SSH credentials configured in the GitHub `production` environment

## 8. GitHub production secrets

Create a GitHub Actions environment named `production` and configure:

```text
PRODUCTION_HOST
PRODUCTION_USER
PRODUCTION_SSH_KEY
PRODUCTION_HOST_FINGERPRINT
PRODUCTION_ENV
```

`PRODUCTION_ENV` is a multiline secret containing the complete production `.env`, for example:

```dotenv
WP_ENV=production
WP_ENVIRONMENT_TYPE=production
WP_HOME=https://example.com
WP_SITEURL=https://example.com/wp

FRANKENPHP_ENABLED=true
FRANKENPHP_MODE=classic
SERVER_NAME=example.com
PHP_VERSION=8.3

DB_NAME=wordpress
DB_USER=wordpress
DB_PASSWORD=<strong-password>
DB_HOST=mysql
DB_PREFIX=wp_

MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress
MYSQL_PASSWORD=<strong-password>
MYSQL_ROOT_PASSWORD=<strong-root-password>

REDIS_HOST=redis
REDIS_PORT=6379

AUTH_KEY=<generated-secret>
SECURE_AUTH_KEY=<generated-secret>
LOGGED_IN_KEY=<generated-secret>
NONCE_KEY=<generated-secret>
AUTH_SALT=<generated-secret>
SECURE_AUTH_SALT=<generated-secret>
LOGGED_IN_SALT=<generated-secret>
NONCE_SALT=<generated-secret>

HEALTHCHECK_URL=https://example.com
```

The workflow writes this secret to `.env` on the server with restrictive permissions. It is never committed to Git.

`PRODUCTION_HOST_FINGERPRINT` should contain the SSH host fingerprint so the deployment connection can verify the intended server instead of blindly accepting a new host key.

## 9. GitHub Actions CI/CD

The deployment pipeline is:

```text
Push to main
    ↓
Composer validation
    ↓
Dependency installation
    ↓
PHP syntax checks
    ↓
Build FrankenPHP image
    ↓
Build PHP-FPM image
    ↓
Push images to GHCR
    ↓
SSH to production
    ↓
Install Docker if missing
    ↓
Clone/update repository
    ↓
Write production .env
    ↓
Authenticate to GHCR
    ↓
Select runtime from FRANKENPHP_ENABLED
    ↓
Pull exact commit image
    ↓
Start/update Docker services
    ↓
Wait for health
    ↓
WordPress database upgrade
    ↓
HTTP health check
    ↓
Mark deployment successful
```

GitHub deployment environments can protect production with branch restrictions and approval rules when desired.

## 10. Backups and rollback

Before deployment, the server attempts a MySQL backup in:

```text
backups/mysql-YYYYMMDD-HHMMSS.sql.gz
```

The last successful image SHA is stored in:

```text
.deployed-tag
```

If the new image fails to start or the health check fails and a previous tag exists, the deployment script attempts to restore the previous application image automatically.

## 11. Separation of code, secrets and state

```text
GitHub
├── source code
├── composer.json
├── composer.lock
├── Dockerfiles
├── Compose files
├── deployment scripts
└── GitHub Actions

Production server
├── .env
├── MySQL volume
├── Redis volume
├── uploads volume
├── Caddy certificate/config volumes
├── deployment state
└── database backups
```

This gives every new WordPress project the same predictable deployment model while allowing the project to choose FrankenPHP or PHP-FPM.
