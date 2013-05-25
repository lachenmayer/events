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
					cwd: 'views'
					src: ['**/*.jade']
					dest: 'public'
					ext: '.html'
				]
				
		# CoffeeScript config
		coffee:
			config:
				files: [
					expand: true
					src: ['views/*.coffee']
					dest: 'public/js'
					ext: '.js'
				]
				
		#Stylus config
		stylus:
			compile:
				files: [
					expand: true
					src: ['views/*.stylus']
					dest: 'public/css'
					ext: '.css'
				]
					

  # Load the NPM tasks.
	grunt.loadNpmTasks 'grunt-contrib-jade';
	grunt.loadNpmTasks 'grunt-contrib-coffee';
	grunt.loadNpmTasks 'grunt-contrib-stylus';
	
	# Register our default tasks.
	grunt.registerTask 'default', ['jade', 'coffee', 'stylus'];