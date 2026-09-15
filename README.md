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

## 7. Production server

The initial server bootstrap is separate from normal application deployments. The application directory is:

```text
/srv/apps/wordpress-bedrock-frankenphp/
```

It should contain the repository files plus a server-only `.env`.

Example production configuration:

```dotenv
WP_ENV=production
WP_ENVIRONMENT_TYPE=production
WP_HOME=https://example.com
WP_SITEURL=https://example.com/wp

FRANKENPHP_ENABLED=true
FRANKENPHP_MODE=classic
SERVER_NAME=example.com

DB_NAME=...
DB_USER=...
DB_PASSWORD=...
DB_HOST=mysql

MYSQL_DATABASE=...
MYSQL_USER=...
MYSQL_PASSWORD=...
MYSQL_ROOT_PASSWORD=...

AUTH_KEY=...
SECURE_AUTH_KEY=...
LOGGED_IN_KEY=...
NONCE_KEY=...
AUTH_SALT=...
SECURE_AUTH_SALT=...
LOGGED_IN_SALT=...
NONCE_SALT=...

HEALTHCHECK_URL=https://example.com
IMAGE_TAG=<commit-sha>
```

`.env` is never committed.

## 8. GitHub Actions CI/CD

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
Update server checkout
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

The workflow targets the GitHub `production` environment. Configure these environment secrets:

```text
PRODUCTION_HOST
PRODUCTION_USER
PRODUCTION_SSH_KEY
```

## 9. Backups and rollback

Before deployment, the server attempts a MySQL backup in:

```text
backups/mysql-YYYYMMDD-HHMMSS.sql.gz
```

The last successful image SHA is stored in:

```text
.deployed-tag
```

If the new image fails to start or the health check fails and a previous tag exists, the deployment script attempts to restore the previous application image automatically.

## 10. Separation of code, secrets and state

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
