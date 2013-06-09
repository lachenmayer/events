module.exports = (grunt) ->
  grunt.initConfig
  
    pkg: grunt.file.readJSON 'package.json'
    
    # Jade config
    jade:
      development:
        options:
          pretty: true
        files: [
          expand: true
          cwd: 'templates'
          src: ['**/*.jade']
          dest: 'public/'
          ext: '.html'
        ]
  
    # CoffeeScript config
    coffee:
      config:
        files: [
          expand: true
          cwd: 'js'
          src: ['**/*.coffee']
          dest: 'public/js'
          ext: '.js'
        ]
        
    #Stylus config
    stylus:
      compile:
        files: [
          expand: true
          cwd: 'css'
          src: ['**/*.stylus']
          dest: 'public/css'
          ext: '.css'
        ]
    
    # Component config
    component:
      install:
        options:
          action: 'install'

    component_build:
      app:
        output: 'build'
        styles: true
        scripts: true
        configure: (builder) ->
          builder.use (require 'component-coffee')
          builder.use (require 'component-stylus')
          builder.use (require 'component-jade')

    # Minification
#     uglify# :
#       app:
#         files:
#           'public/js/app.js' : ['build/app.js']

    # Copying files
    copy:
      app_css:
        src: 'build/app.css'
        dest: 'public/css/app.css'
      app_js:
        src: 'build/app.js'
        dest: 'public/js/app.js'
      app_images:
        src: 'images/*'
        dest: 'public/'
        filter: 'isFile'
        flatten: true

    # Watch config
    watch:
      jade:
        files: ['templates/*.jade']
        tasks: ['jade', 'component_private']
      coffee:
        files: ['js/*.coffee']
        tasks: ['coffee', 'component_private']
      stylus:
        files: ['css/*.styl']
        tasks: ['stylus', 'component_private']
      lib_coffee:
        files: 'lib/**/*.coffee'
        tasks: 'component_private'
      lib_jade:
        files: 'lib/**/*.jade'
        tasks: 'component_private'
      lib_stylus:
        files: 'lib/**/*.styl'
        tasks: 'component_private'
      component:
        files: '**/component.json'
        tasks: 'component_update'

  # Load dependencies
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-component'
  grunt.loadNpmTasks 'grunt-component-build'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'component_private', [
    'component_build',
    'copy'
  ]
  grunt.registerTask 'component_update', [
    'component',
    'component_build',
    'copy'
  ]
  
  # Register our default tasks
  grunt.registerTask 'default',  [
    'jade',
    'coffee',
    'stylus',
    'component_update'
  ]
