JADE_FILES 		= ['views/*.jade']
SCRIPT_FILES 	= ['views/*.coffee']
STYLUS_FILES 	= ['views/*.stylus']

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
					src: JADE_FILES
					dest: 'public'
					ext: '.html'
				]
				
		# CoffeeScript config
		coffee:
			config:
				files: [
					expand: true
					src: SCRIPT_FILES
					dest: 'public/js'
					ext: '.js'
				]
				
		#Stylus config
		stylus:
			compile:
				files: [
					expand: true
					src: STYLUS_FILES
					dest: 'public/css'
					ext: '.css'
				]
				
		# Watch config
		watch:
			scripts:
				files: SCRIPT_FILES
				tasks: ['coffee']
			jade:
				files: JADE_FILES
				tasks: ['jade']
			stylus:
				files: STYLUS_FILES
				tasks: ['stylus']
			
					
	# Copy libraries
	grunt.registerTask 'copy-backbone', ->
		grunt.file.mkdir 'public/js/lib'
		grunt.file.copy 'node_modules/backbone/backbone-min.js', 'public/js/lib/backbone-min.js'

  # Load the NPM tasks.
	grunt.loadNpmTasks 'grunt-contrib-jade';
	grunt.loadNpmTasks 'grunt-contrib-coffee';
	grunt.loadNpmTasks 'grunt-contrib-stylus';
	grunt.loadNpmTasks 'grunt-contrib-watch';
	
	# Register our default tasks.
	grunt.registerTask 'default', ['jade', 'coffee', 'stylus', 'copy-backbone'];