module.exports = (grunt) ->
	grunt.initConfig
		pkg: grunt.file.readJSON('package.json'),
		
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
		    output: 'public/build'
				
		# Watch config
		watch:
		  jade:
  		  files: ['templates/*.jade']
  		  tasks: 'jade'
  		coffee:
        files: ['js/*.coffee']
        tasks: 'coffee'
      stylus:
        files: ['css/*.stylus']
        tasks: 'stylus'
      component:
        files: 'component.json'
        tasks: 'component'

  # Load dependencies
	grunt.loadNpmTasks 'grunt-contrib-jade'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-stylus'
	grunt.loadNpmTasks 'grunt-component'
	grunt.loadNpmTasks 'grunt-component-build'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	
	# Register our default tasks
	grunt.registerTask 'default',  [
	  'jade',
	  'coffee',
	  'stylus',
	  'component',
	  'component_build',
  ]
