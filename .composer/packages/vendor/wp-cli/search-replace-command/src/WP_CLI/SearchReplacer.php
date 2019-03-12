<?php

namespace WP_CLI;

class SearchReplacer {

	private $from, $to;
	private $recurse_objects;
	private $regex;
	private $regex_flags;
	private $regex_delimiter;
	private $logging;
	private $log_data;
	private $max_recursion;

	/**
	 * @param string  $from            String we're looking to replace.
	 * @param string  $to              What we want it to be replaced with.
	 * @param bool    $recurse_objects Should objects be recursively replaced?
	 * @param bool    $regex           Whether `$from` is a regular expression.
	 * @param string  $regex_flags     Flags for regular expression.
	 * @param string  $regex_delimiter Delimiter for regular expression.
	 * @param bool    $logging         Whether logging.
	 */
	function __construct( $from, $to, $recurse_objects = false, $regex = false, $regex_flags = '', $regex_delimiter = '/', $logging = false ) {
		$this->from = $from;
		$this->to = $to;
		$this->recurse_objects = $recurse_objects;
		$this->regex = $regex;
		$this->regex_flags = $regex_flags;
		$this->regex_delimiter = $regex_delimiter;
		$this->logging = $logging;
		$this->clear_log_data();

		// Get the XDebug nesting level. Will be zero (no limit) if no value is set
		$this->max_recursion = intval( ini_get( 'xdebug.max_nesting_level' ) );
	}

	/**
	 * Take a serialised array and unserialise it replacing elements as needed and
	 * unserialising any subordinate arrays and performing the replace on those too.
	 * Ignores any serialized objects unless $recurse_objects is set to true.
	 *
	 * @param array|string $data            The data to operate on.
	 * @param bool         $serialised      Does the value of $data need to be unserialized?
	 *
	 * @return array       The original array with all elements replaced as needed.
	 */
	function run( $data, $serialised = false ) {
		return $this->_run( $data, $serialised );
	}

	/**
	 * @param int          $recursion_level Current recursion depth within the original data.
	 * @param array        $visited_data    Data that has been seen in previous recursion iterations.
	 */
	private function _run( $data, $serialised, $recursion_level = 0, $visited_data = array() ) {

		// some unseriliased data cannot be re-serialised eg. SimpleXMLElements
		try {

			if ( $this->recurse_objects ) {

				// If we've reached the maximum recursion level, short circuit
				if ( $this->max_recursion != 0 && $recursion_level >= $this->max_recursion ) {
					return $data;
				}

				if ( is_array( $data ) || is_object( $data ) ) {
					// If we've seen this exact object or array before, short circuit
					if ( in_array( $data, $visited_data, true ) ) {
						return $data; // Avoid infinite loops when there's a cycle
					}
					// Add this data to the list of
					$visited_data[] = $data;
				}
			}

			if ( is_string( $data ) && ( $unserialized = @unserialize( $data ) ) !== false ) {
				$data = $this->_run( $unserialized, true, $recursion_level + 1 );
			}

			elseif ( is_array( $data ) ) {
				$keys = array_keys( $data );
				foreach ( $keys as $key ) {
					$data[ $key ]= $this->_run( $data[$key], false, $recursion_level + 1, $visited_data );
				}
			}

			elseif ( $this->recurse_objects && is_object( $data ) ) {
				foreach ( $data as $key => $value ) {
					$data->$key = $this->_run( $value, false, $recursion_level + 1, $visited_data );
				}
			}

			else if ( is_string( $data ) ) {
				if ( $this->logging ) {
					$old_data = $data;
				}
				if ( $this->regex ) {
					$search_regex = $this->regex_delimiter;
					$search_regex .= $this->from;
					$search_regex .= $this->regex_delimiter;
					$search_regex .= $this->regex_flags;
					$data = preg_replace( $search_regex, $this->to, $data );
				} else {
					$data = str_replace( $this->from, $this->to, $data );
				}
				if ( $this->logging && $old_data !== $data ) {
					$this->log_data[] = $old_data;
				}
			}

			if ( $serialised )
				return serialize( $data );

		} catch( Exception $error ) {

		}

		return $data;
	}

	/**
	 * Gets existing data saved for this run when logging.
	 * @return array Array of data strings, prior to replacements.
	 */
	public function get_log_data() {
		return $this->log_data;
	}

	/**
	 * Clears data stored for logging.
	 */
	public function clear_log_data() {
		$this->log_data = array();
	}
}

