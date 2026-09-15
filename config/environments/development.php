<?php

use Roots\WPConfig\Env;

Config::define('WP_DEBUG', true);
Config::define('WP_DEBUG_LOG', true);
Config::define('WP_DEBUG_DISPLAY', false);
Config::define('SCRIPT_DEBUG', true);
Config::define('SAVEQUERIES', Env::get('SAVEQUERIES', false));
