<?php

require dirname(__DIR__) . '/vendor/autoload.php';

use Roots\WPConfig\Application;

Application::configure(dirname(__DIR__))->boot();
