<?php

use Roots\WPConfig\Config;
use function Env\env;

Env\Env::$options
    = Env\Env::CONVERT_BOOL
    | Env\Env::CONVERT_NULL
    | Env\Env::CONVERT_INT
    | Env\Env::STRIP_QUOTES
    | Env\Env::LOCAL_FIRST;

$root_dir = dirname(__DIR__);
$webroot_dir = $root_dir . '/web';

if (file_exists($root_dir . '/.env')) {
    $env_files = file_exists($root_dir . '/.env.local')
        ? ['.env', '.env.local']
        : ['.env'];

    $repository = Dotenv\Repository\RepositoryBuilder::createWithNoAdapters()
        ->addAdapter(Dotenv\Repository\Adapter\EnvConstAdapter::class)
        ->addAdapter(Dotenv\Repository\Adapter\PutenvAdapter::class)
        ->immutable()
        ->make();

    Dotenv\Dotenv::create($repository, $root_dir, $env_files, false)->load();
}

define('WP_ENV', env('WP_ENV') ?: 'production');

if (!defined('WP_ENVIRONMENT_TYPE')) {
    $type = env('WP_ENVIRONMENT_TYPE');
    if ($type) {
        Config::define('WP_ENVIRONMENT_TYPE', $type);
    } elseif (in_array(WP_ENV, ['production', 'staging', 'development', 'local'], true)) {
        Config::define('WP_ENVIRONMENT_TYPE', WP_ENV);
    }
}

Config::define('WP_HOME', env('WP_HOME'));
Config::define('WP_SITEURL', env('WP_SITEURL'));

Config::define('CONTENT_DIR', '/app');
Config::define('WP_CONTENT_DIR', $webroot_dir . Config::get('CONTENT_DIR'));
Config::define('WP_CONTENT_URL', Config::get('WP_HOME') . Config::get('CONTENT_DIR'));

Config::define('DB_NAME', env('DB_NAME'));
Config::define('DB_USER', env('DB_USER'));
Config::define('DB_PASSWORD', env('DB_PASSWORD'));
Config::define('DB_HOST', env('DB_HOST') ?: 'mysql');
Config::define('DB_CHARSET', 'utf8mb4');
Config::define('DB_COLLATE', '');
$table_prefix = env('DB_PREFIX') ?: 'wp_';

Config::define('AUTH_KEY', env('AUTH_KEY'));
Config::define('SECURE_AUTH_KEY', env('SECURE_AUTH_KEY'));
Config::define('LOGGED_IN_KEY', env('LOGGED_IN_KEY'));
Config::define('NONCE_KEY', env('NONCE_KEY'));
Config::define('AUTH_SALT', env('AUTH_SALT'));
Config::define('SECURE_AUTH_SALT', env('SECURE_AUTH_SALT'));
Config::define('LOGGED_IN_SALT', env('LOGGED_IN_SALT'));
Config::define('NONCE_SALT', env('NONCE_SALT'));

Config::define('AUTOMATIC_UPDATER_DISABLED', true);
Config::define('DISABLE_WP_CRON', env('DISABLE_WP_CRON') ?: false);
Config::define('DISALLOW_FILE_EDIT', true);

if (WP_ENV === 'production') {
    Config::define('DISALLOW_FILE_MODS', true);
}

Config::define('WP_POST_REVISIONS', env('WP_POST_REVISIONS') ?? true);
Config::define('CONCATENATE_SCRIPTS', false);

Config::define('WP_DEBUG_DISPLAY', false);
Config::define('WP_DEBUG_LOG', false);
Config::define('SCRIPT_DEBUG', false);
ini_set('display_errors', '0');

if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    $_SERVER['HTTPS'] = 'on';
}

$env_config = __DIR__ . '/environments/' . WP_ENV . '.php';
if (file_exists($env_config)) {
    require_once $env_config;
}

Config::apply();

if (!defined('ABSPATH')) {
    define('ABSPATH', $webroot_dir . '/wp/');
}
