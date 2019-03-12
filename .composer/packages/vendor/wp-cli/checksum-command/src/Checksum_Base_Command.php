<?php

use \WP_CLI\Utils;

/**
 * Base command that all checksum commands rely on.
 *
 * @package wp-cli
 */
class Checksum_Base_Command extends WP_CLI_Command {

	/**
	 * Read a remote file and return its contents.
	 *
	 * @param string $url URL of the remote file to read.
	 *
	 * @return mixed
	 */
	protected static function _read( $url ) {
		$headers  = array( 'Accept' => 'application/json' );
		$response = Utils\http_request( 'GET', $url, null, $headers,
			array( 'timeout' => 30 ) );
		if ( 200 === $response->status_code ) {
			return $response->body;
		}
		WP_CLI::error( "Couldn't fetch response from {$url} (HTTP code {$response->status_code})." );
	}

	/**
	 * Recursively get the list of files for a given path.
	 *
	 * @param string $path Root path to start the recursive traversal in.
	 *
	 * @return array<string>
	 */
	protected function get_files( $path ) {
		$filtered_files = array();
		try {
			$files = new RecursiveIteratorIterator(
				new RecursiveDirectoryIterator( $path,
					RecursiveDirectoryIterator::SKIP_DOTS ),
				RecursiveIteratorIterator::CHILD_FIRST
			);
			foreach ( $files as $file_info ) {
				$pathname = substr( $file_info->getPathname(), strlen( $path ) );
				if ( $file_info->isFile() && $this->filter_file( $pathname ) ) {
					$filtered_files[] = $pathname;
				}
			}
		} catch ( Exception $e ) {
			WP_CLI::error( $e->getMessage() );
		}

		return $filtered_files;
	}

	/**
	 * Whether to include the file in the verification or not.
	 *
	 * Can be overridden in subclasses.
	 *
	 * @param string $filepath Path to a file.
	 *
	 * @return bool
	 */
	protected function filter_file( $filepath ) {
		return true;
	}
}
