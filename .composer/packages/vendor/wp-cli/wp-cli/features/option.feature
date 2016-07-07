Feature: Manage WordPress options

  Scenario: Option CRUD
    Given a WP install

    # String values
    When I run `wp option add str_opt 'bar'`
    Then STDOUT should not be empty

    When I run `wp option get str_opt`
    Then STDOUT should be:
      """
      bar
      """

    When I run `wp option list`
    Then STDOUT should not be empty

    When I run `wp option list`
    Then STDOUT should contain:
      """
      str_opt	bar
      """

    When I run `wp option list --autoload=off`
    Then STDOUT should not contain:
      """
      str_opt	bar
      """

    When I run `wp option list --search='str_o*'`
    Then STDOUT should be a table containing rows:
      | option_name  | option_value  |
      | str_opt      | bar           |

    When I run `wp option list --search='str_o*' --format=total_bytes`
    Then STDOUT should be:
      """
      3
      """

    When I run `wp option list`
    Then STDOUT should contain:
      """
      home	http://example.com
      """

    When I run `wp option add auto_opt --autoload=no 'bar'`
    Then STDOUT should not be empty

    When I run `wp option list --search='auto_opt' --autoload`
    Then STDOUT should not be empty

    When I run `wp option list | grep -q "str_opt"`
    Then the return code should be 0

    When I run `wp option delete str_opt`
    Then STDOUT should not be empty

    When I run `wp option list`
    Then STDOUT should not contain:
      """
      str_opt	bar
      """

    When I try `wp option get str_opt`
    Then the return code should be 1

    # Integer values
    When I run `wp option update blog_public 1`
    Then STDOUT should not be empty

    When I run `wp option update blog_public 0`
    Then STDOUT should contain:
      """
      Success: Updated 'blog_public' option.
      """

    When I run the previous command again
    Then STDOUT should contain:
      """
      Success: Value passed for 'blog_public' option is unchanged.
      """

    When I run `wp option get blog_public`
    Then STDOUT should be:
      """
      0
      """


    # JSON values
    When I run `wp option set json_opt '[ 1, 2 ]' --format=json`
    Then STDOUT should not be empty

    When I run the previous command again
    Then STDOUT should not be empty

    When I run `wp option get json_opt --format=json`
    Then STDOUT should be:
      """
      [1,2]
      """


    # Reading from files
    Given a value.json file:
      """
      {
        "foo": "bar",
        "list": [1, 2, 3]
      }
      """
    When I run `wp option set foo --format=json < value.json`
    And I run `wp option get foo --format=json`
    Then STDOUT should be JSON containing:
      """
      {
        "foo": "bar",
        "list": [1, 2, 3]
      }
      """

  @require-wp-4.2
  Scenario: Update autoload value for custom option
    Given a WP install
    And I run `wp option add hello world --autoload=no`

    When I run `wp option update hello universe`
    Then STDOUT should not be empty

    When I run `wp option list --search='hello' --fields=option_name,option_value,autoload`
    Then STDOUT should be a table containing rows:
      | option_name  | option_value   | autoload |
      | hello        | universe       | no       |

    When I run `wp option update hello island --autoload=yes`
    Then STDOUT should not be empty

    When I run `wp option list --search='hello' --fields=option_name,option_value,autoload`
    Then STDOUT should be a table containing rows:
      | option_name  | option_value   | autoload |
      | hello        | island         | yes      |
