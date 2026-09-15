<?php

use Roots\WPConfig\Env;

require_once dirname(__DIR__) . '/vendor/autoload.php';

Env::init();

$webroot_dir = dirname(__DIR__) . '/web';

/**
 * URLs
 */
Config::define('WP_HOME', Env::get('WP_HOME', 'http://localhost'));
Config::define('WP_SITEURL', Env::get('WP_SITEURL', 'http://localhost/wp'));

/**
 * Environment
 */
Config::define('WP_ENV', Env::get('WP_ENV', 'production'));

/**
 * Database
 */
Config::define('DB_NAME', Env::get('DB_NAME', 'wordpress'));
Config::define('DB_USER', Env::get('DB_USER', 'wordpress'));
Config::define('DB_PASSWORD', Env::get('DB_PASSWORD', 'wordpress'));
Config::define('DB_HOST', Env::get('DB_HOST', 'mysql'));
Config::define('DB_CHARSET', 'utf8mb4');
Config::define('DB_COLLATE', '');
Config::define('DB_PREFIX', Env::get('DB_PREFIX', 'wp_'));

/**
 * Authentication unique keys and salts.
 * Set these in production. Do not commit real values.
 */
Config::define('AUTH_KEY', Env::get('AUTH_KEY', 'change-me'));
Config::define('SECURE_AUTH_KEY', Env::get('SECURE_AUTH_KEY', 'change-me'));
Config::define('LOGGED_IN_KEY', Env::get('LOGGED_IN_KEY', 'change-me'));
Config::define('NONCE_KEY', Env::get('NONCE_KEY', 'change-me'));
Config::define('AUTH_SALT', Env::get('AUTH_SALT', 'change-me'));
Config::define('SECURE_AUTH_SALT', Env::get('SECURE_AUTH_SALT', 'change-me'));
Config::define('LOGGED_IN_SALT', Env::get('LOGGED_IN_SALT', 'change-me'));
Config::define('NONCE_SALT', Env::get('NONCE_SALT', 'change-me'));

/**
 * Redis.
 */
Config::define('WP_REDIS_HOST', Env::get('REDIS_HOST', 'redis'));
Config::define('WP_REDIS_PORT', Env::get('REDIS_PORT', '6379'));

$table_prefix = DB_PREFIX;

/**
 * Debugging.
 */
if (Env::get('WP_ENV') === 'development') {
    Config::define('WP_DEBUG', true);
    Config::define('WP_DEBUG_LOG', true);
    Config::define('WP_DEBUG_DISPLAY', false);
} else {
    Config::define('WP_DEBUG', false);
    Config::define('WP_DEBUG_LOG', false);
    Config::define('WP_DEBUG_DISPLAY', false);
}

Config::define('DISALLOW_FILE_EDIT', true);

if (!defined('ABSPATH')) {
    define('ABSPATH', $webroot_dir . '/wp/');
}

require_once ABSPATH . 'wp-settings.php';
