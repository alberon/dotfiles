<?php

/**
 * Adds, updates, removes, and lists user terms.
 *
 * ## EXAMPLES
 *
 *     # Set user terms
 *     $ wp user term set 123 test category
 *     Success: Set terms.
 */
class User_Term_Command extends \WP_CLI\CommandWithTerms {
	protected $obj_type = 'user';
}
