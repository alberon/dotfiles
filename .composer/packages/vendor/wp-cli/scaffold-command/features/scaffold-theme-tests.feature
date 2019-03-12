Feature: Scaffold theme unit tests

  Background:
    Given a WP install
    And I run `wp theme install p2`
    And I run `wp scaffold child-theme p2child --parent_theme=p2`

    When I run `wp theme path`
    Then save STDOUT as {THEME_DIR}

  Scenario: Scaffold theme tests
    When I run `wp scaffold theme-tests p2child`
    Then STDOUT should not be empty
    And the {THEME_DIR}/p2child/tests directory should contain:
      """
      bootstrap.php
      test-sample.php
      """
    And the {THEME_DIR}/p2child/tests/bootstrap.php file should contain:
      """
      register_theme_directory( $theme_root );
      """
    And the {THEME_DIR}/p2child/tests/bootstrap.php file should contain:
      """
      * @package P2child
      """
    And the {THEME_DIR}/p2child/tests/test-sample.php file should contain:
      """
      * @package P2child
      """
    And the {THEME_DIR}/p2child/bin directory should contain:
      """
      install-wp-tests.sh
      """
    And the {THEME_DIR}/p2child/phpunit.xml.dist file should exist
    And the {THEME_DIR}/p2child/phpcs.xml.dist file should exist
    And the {THEME_DIR}/p2child/circle.yml file should not exist
    And the {THEME_DIR}/p2child/.gitlab-ci.yml file should not exist
    And the {THEME_DIR}/p2child/.travis.yml file should contain:
      """
      script:
        - |
          if [[ ! -z "$WP_VERSION" ]] ; then
            phpunit
            WP_MULTISITE=1 phpunit
          fi
        - |
          if [[ "$WP_TRAVISCI" == "phpcs" ]] ; then
            phpcs
          fi
      """
    And the {THEME_DIR}/p2child/.travis.yml file should contain:
      """
      matrix:
        include:
          - php: 7.1
            env: WP_VERSION=latest
          - php: 7.0
            env: WP_VERSION=latest
          - php: 5.6
            env: WP_VERSION=latest
          - php: 5.6
            env: WP_VERSION=trunk
          - php: 5.6
            env: WP_TRAVISCI=phpcs
          - php: 5.3
            env: WP_VERSION=latest
      """

    When I run `wp eval "if ( is_executable( '{THEME_DIR}/p2child/bin/install-wp-tests.sh' ) ) { echo 'executable'; } else { exit( 1 ); }"`
    Then STDOUT should be:
      """
      executable
      """

    # Warning: overwriting generated functions.php file, so functions.php file loaded only tests beyond here...
    Given a wp-content/themes/p2child/functions.php file:
      """
      <?php echo __FILE__ . " loaded.\n";
      """
    And I run `MYSQL_PWD=password1 mysql -u wp_cli_test -e "DROP DATABASE IF EXISTS wp_cli_test_scaffold"`
    And I try `rm -fr /tmp/behat-wordpress-tests-lib`
    And I try `rm -fr /tmp/behat-wordpress`
	And I try `WP_TESTS_DIR=/tmp/behat-wordpress-tests-lib WP_CORE_DIR=/tmp/behat-wordpress {THEME_DIR}/p2child/bin/install-wp-tests.sh wp_cli_test_scaffold wp_cli_test password1 localhost latest`
    Then the return code should be 0

    When I run `cd {THEME_DIR}/p2child; WP_TESTS_DIR=/tmp/behat-wordpress-tests-lib phpunit`
    Then STDOUT should contain:
      """
      p2child/functions.php loaded.
      """
    And STDOUT should contain:
      """
      Running as single site
      """
    And STDOUT should contain:
      """
      OK (1 test, 1 assertion)
      """

    When I run `cd {THEME_DIR}/p2child; WP_MULTISITE=1 WP_TESTS_DIR=/tmp/behat-wordpress-tests-lib phpunit`
    Then STDOUT should contain:
      """
      p2child/functions.php loaded.
      """
    And STDOUT should contain:
      """
      Running as multisite
      """
    And STDOUT should contain:
      """
      OK (1 test, 1 assertion)
      """

  Scenario: Scaffold theme tests invalid theme
    When I try `wp scaffold theme-tests p3child`
    Then STDERR should be:
      """
      Error: Invalid theme slug specified. The theme 'p3child' does not exist.
      """
    And the return code should be 1

  Scenario: Scaffold theme tests with Circle as the provider
    When I run `wp scaffold theme-tests p2child --ci=circle`
    Then STDOUT should not be empty
    And the {THEME_DIR}/p2child/.travis.yml file should not exist
    And the {THEME_DIR}/p2child/circle.yml file should contain:
      """
      version: 5.6.22
      """

  Scenario: Scaffold theme tests with Gitlab as the provider
    When I run `wp scaffold theme-tests p2child --ci=gitlab`
    Then STDOUT should not be empty
    And the {THEME_DIR}/p2child/.travis.yml file should not exist
    And the {THEME_DIR}/p2child/.gitlab-ci.yml file should contain:
      """
      MYSQL_DATABASE
      """

  Scenario: Scaffold theme tests with invalid slug

    When I try `wp scaffold theme-tests .`
    Then STDERR should be:
      """
      Error: Invalid theme slug specified. The slug cannot be '.' or '..'.
      """
    And the return code should be 1

    When I try `wp scaffold theme-tests ../`
    Then STDERR should be:
      """
      Error: Invalid theme slug specified. The target directory '{RUN_DIR}/wp-content/themes/../' is not in '{RUN_DIR}/wp-content/themes'.
      """
    And the return code should be 1

  Scenario: Scaffold theme tests with invalid directory
    When I try `wp scaffold theme-tests p2 --dir=non-existent-dir`
    Then STDERR should be:
      """
      Error: Invalid theme directory specified. No such directory 'non-existent-dir'.
      """
    And the return code should be 1

    # Temporarily move.
    When I run `mv -f {THEME_DIR}/p2 {THEME_DIR}/hide-p2 && touch {THEME_DIR}/p2`
    Then the return code should be 0

    When I try `wp scaffold theme-tests p2`
    Then STDERR should be:
      """
      Error: Invalid theme slug specified. No such target directory '{THEME_DIR}/p2'.
      """
    And the return code should be 1

    # Restore.
    When I run `rm -f {THEME_DIR}/p2 && mv -f {THEME_DIR}/hide-p2 {THEME_DIR}/p2`
    Then the return code should be 0

  Scenario: Scaffold theme tests with a symbolic link
    # Temporarily move the whole theme dir and create a symbolic link to it.
    When I run `mv -f {THEME_DIR} {RUN_DIR}/alt-themes && ln -s {RUN_DIR}/alt-themes {THEME_DIR}`
    Then the return code should be 0

    When I run `wp scaffold theme-tests p2`
    Then STDOUT should not be empty
    And the {THEME_DIR}/p2/tests directory should contain:
      """
      bootstrap.php
      """

    # Restore.
    When I run `unlink {THEME_DIR} && mv -f {RUN_DIR}/alt-themes {THEME_DIR}`
    Then the return code should be 0
