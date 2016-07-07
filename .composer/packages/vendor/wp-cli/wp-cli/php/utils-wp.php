<?php

// Utilities that depend on WordPress code.

namespace WP_CLI\Utils;

function wp_not_installed() {
	if ( !is_blog_installed() && !defined( 'WP_INSTALLING' ) ) {
		\WP_CLI::error(
			"The site you have requested is not installed.\n" .
			'Run `wp core install`.' );
	}
}

function wp_debug_mode() {
	if ( \WP_CLI::get_config( 'debug' ) ) {
		if ( !defined( 'WP_DEBUG' ) )
			define( 'WP_DEBUG', true );

		error_reporting( E_ALL & ~E_DEPRECATED & ~E_STRICT );
	} else {
		\wp_debug_mode();
	}

	// XDebug already sends errors to STDERR
	ini_set( 'display_errors', function_exists( 'xdebug_debug_zval' ) ? false : 'STDERR' );
}

function replace_wp_die_handler() {
	\remove_filter( 'wp_die_handler', '_default_wp_die_handler' );
	\add_filter( 'wp_die_handler', function() { return __NAMESPACE__ . '\\' . 'wp_die_handler'; } );
}

function wp_die_handler( $message ) {
	if ( is_wp_error( $message ) ) {
		$message = $message->get_error_message();
	}

	if ( preg_match( '|^\<h1>(.+?)</h1>|', $message, $matches ) ) {
		$message = $matches[1];
	}

	$message = html_entity_decode( $message );

	\WP_CLI::error( $message );
}

function wp_redirect_handler( $url ) {
	\WP_CLI::warning( 'Some code is trying to do a URL redirect. Backtrace:' );

	ob_start();
	debug_print_backtrace();
	fwrite( STDERR, ob_get_clean() );

	return $url;
}

function maybe_require( $since, $path ) {
	if ( version_compare( str_replace( array( '-src' ), '', $GLOBALS['wp_version'] ), $since, '>=' ) ) {
		require $path;
	}
}

function get_upgrader( $class ) {
	if ( !class_exists( '\WP_Upgrader' ) )
		require_once ABSPATH . 'wp-admin/includes/class-wp-upgrader.php';

	return new $class( new \WP_CLI\UpgraderSkin );
}

/**
 * Converts a plugin basename back into a friendly slug.
 */
function get_plugin_name( $basename ) {
	if ( false === strpos( $basename, '/' ) )
		$name = basename( $basename, '.php' );
	else
		$name = dirname( $basename );

	return $name;
}

function is_plugin_skipped( $file ) {
	$name = get_plugin_name( str_replace( WP_PLUGIN_DIR . '/', '', $file ) );

	$skipped_plugins = \WP_CLI::get_runner()->config['skip-plugins'];
	if ( true === $skipped_plugins )
		return true;

	if ( ! is_array( $skipped_plugins ) ) {
		$skipped_plugins = explode( ',', $skipped_plugins );
	}

	return in_array( $name, array_filter( $skipped_plugins ) );
}

function get_theme_name( $path ) {
	return basename( $path );
}

function is_theme_skipped( $path ) {
	$name = get_theme_name( $path );

	$skipped_themes = \WP_CLI::get_runner()->config['skip-themes'];
	if ( true === $skipped_themes )
		return true;

	if ( ! is_array( $skipped_themes ) ) {
		$skipped_themes = explode( ',', $skipped_themes );
	}

	return in_array( $name, array_filter( $skipped_themes ) );
}

/**
 * Register the sidebar for unused widgets
 * Core does this in /wp-admin/widgets.php, which isn't helpful
 */
function wp_register_unused_sidebar() {

	register_sidebar(array(
		'name' => __('Inactive Widgets'),
		'id' => 'wp_inactive_widgets',
		'class' => 'inactive-sidebar',
		'description' => __( 'Drag widgets here to remove them from the sidebar but keep their settings.' ),
		'before_widget' => '',
		'after_widget' => '',
		'before_title' => '',
		'after_title' => '',
	));

}

/**
 * Clear all of the caches for memory management
 */
function wp_clear_object_cache() {
	global $wpdb, $wp_object_cache;

	$wpdb->queries = array(); // or define( 'WP_IMPORTING', true );

	if ( ! is_object( $wp_object_cache ) ) {
		return;
	}

	$wp_object_cache->group_ops = array();
	$wp_object_cache->stats = array();
	$wp_object_cache->memcache_debug = array();
	$wp_object_cache->cache = array();

	if ( is_callable( $wp_object_cache, '__remoteset' ) ) {
		$wp_object_cache->__remoteset(); // important
	}
}
