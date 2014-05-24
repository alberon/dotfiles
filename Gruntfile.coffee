module.exports = (grunt) ->

  grunt.initConfig

    # Run reload tmux configuration
    shell:
      tmux:
        command: 'tmux source ~/.tmux.conf \\; display "Reloaded ~/.tmux.conf"'

    # Watch
    watch:
      options:
        spawn: false

      gruntfile:
        files: ['Gruntfile.coffee']

      tmux:
        files: ['.tmux.conf']
        tasks: ['shell:tmux']

  # Run watch by default
  grunt.registerTask('default', ['watch'])

  # Lazy-load plugins & custom tasks
  require('jit-grunt')(grunt, {
  })({
    customTasksDir: 'tasks'
  })
