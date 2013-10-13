module.exports = (grunt) ->
  ################################
  ## USER SETTINGS - EDIT BELOW ##
  ################################

  # Self-managed references for third-party files. These are either relative to
  # project root or HTTP(S) addresses
  vendorFiles =
    js: []
    css: []

  # Paths
  sourceDir = 'src' # Where the source lives
  compileDir = 'lib' # Where pre-processed and minified (except JS) code lives
  buildDir = 'build' # Where fully minified and concatenated output code lives
  configDir = 'config' # Where to put config files
  vendorDir = 'bower_components' # Where the vendor files are originally

  ################################
  ## DO NOT EDIT ANYTHING BELOW ##
  ################################

  # Load Grunt tasks
  grunt.loadNpmTasks 'grunt-contrib-jshint'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-conventional-changelog'
  grunt.loadNpmTasks 'grunt-bump'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-karma'
  grunt.loadNpmTasks 'grunt-ngmin'

  # Configuration
  grunt.initConfig
    ## Common settings

    # Package metadata
    pkg: grunt.file.readJSON 'package.json'

    # File locations
    files:
      vendor: vendorFiles
      source:
        js: ["#{sourceDir}/**/*.js", "!#{sourceDir}/**/*.spec.js"]
        jsTest: ["!#{sourceDir}/**/*.spec.js"]
        coffee: ["#{sourceDir}/**/*.coffee", "!#{sourceDir}/**/*.spec.coffee"]
        coffeeTest: ["!#{sourceDir}/**/*.spec.coffee"]
        css: ["#{sourceDir}/**/*.{css,styl,less}"]
      compile:
        js: ["#{compileDir}/**/*.js", "!#{compileDir}/**/*.spec.js"]
        jsTest: ["!#{compileDir}/**/*.spec.js"]
        css: ["#{compileDir}/**/*.css"]
      build:
        js: ["#{buildDir}/**/*.js"]

    # Metadata like the banner to be inserted above released source code
    meta:
      banner: '/**\n' + ' * <%= pkg.name %> - v<%= pkg.version %> - <%= grunt.template.today(\'yyyy-mm-dd\') %>\n' + ' * <%= pkg.homepage %>\n' + ' *\n' + ' * Copyright (c) <%= grunt.template.today(\'yyyy\') %> <%= pkg.author %>\n' + ' * Licensed <%= pkg.licenses.type %> <<%= pkg.licenses.url %>>\n' + ' */\n'

    # Automatic changelog
    changelog:
      options:
        dest: 'CHANGELOG.md'
        template: 'changelog.tpl'

    # Bump version to both Bower and NPM
    bump:
      options:
        files: ['package.json', 'bower.json']
        commit: false
        commitMessage: 'chore(release): v%VERSION%'
        commitFiles: ['package.json', 'client/bower.json']
        createTag: false
        tagName: 'v%VERSION%'
        tagMessage: 'Version %VERSION%'
        push: false
        pushTo: 'origin'

    ## Build-related tasks

    # First prepare for minification
    ngmin:
      compile:
        files: [
          src: '<%= files.compile.js %>'
          cwd: compileDir
          dest: compileDir
          expand: true
        ]

    # Then concatenate all JS and CSS files into respective release files
    concat:
      js:
        options:
          banner: '<%= meta.banner %>'
        src: [
          '<%= files.vendor.js %>'
          '(function ( window, angular, undefined ) {'
          '<%= files.compile.js %>'
          '})( window, window.angular );'
        ]
        dest: "#{buildDir}/<%= pkg.name %>-<%= pkg.version %>.js"

      css:
        options:
          banner: '<%= meta.banner %>'
        src: [
          '<%= files.vendor.css %>'
          '<%= files.compile.css %>'
        ]
        dest: "#{buildDir}/<%= pkg.name %>-<%= pkg.version %>.css"

    # Finally uglify the JS release file
    uglify:
      compile:
        options:
          banner: '<%= meta.banner %>'
        files:
          '<%= concat.js.dest %>': '<%= concat.js.dest %>'

    ## Style police

    jshint:
      src: '<%= files.compile.js %>'
      test: '<%= files.compile.jsTest %>'
      options:
        curly: true
        immed: true
        newcap: true
        noarg: true
        sub: true
        boss: true
        eqnull: true
      globals: {}

    coffeelint:
      options:
        max_line_length:
          level: 'warn'
      src:
        files:
          src: '<%= files.source.coffee %>'
      test:
        files:
          src: '<%= files.source.coffeeTest %>'

    ## Testing
    # TODO review

    karma:
      options:
        configFile: "#{configDir}/karma-unit.js"
      unit:
        runnerPort: 9101
        background: true
      continuous:
        singleRun: true

    karmaconfig:
      unit:
        dir: '<%= build_dir %>'
        src: ['<%= vendor_files.js %>', '<%= html2js.app.dest %>', '<%= html2js.common.dest %>', '<%= html2js.jade_app.dest %>', '<%= html2js.jade_common.dest %>', 'vendor/angular-mocks/angular-mocks.js']

    ## Build `index.html` to include references to all JS and CSS files

    index:
      source:
        dir: sourceDir
        src: [
          '<%= files.vendor.js %>'
          '<%= files.vendor.css %>'
          '<%= files.source.js %>'
          '<%= files.source.coffee %>'
          '<%= files.source.css %>'
        ]

      compile:
        dir: compileDir
        src: [
          '<%= files.vendor.js %>'
          '<%= files.vendor.css %>'
          '<%= files.compile.js %>'
          '<%= files.compile.css %>'
        ]

      build:
        dir: buildDir
        src: [
          '<%= concat.js.dest %>'
          '<%= concat.css.dest %>'
        ]

  # Build tasks
  grunt.registerTask 'watch', ['index:source']
  grunt.registerTask 'default', ['source', 'compile', 'build']
  grunt.registerTask 'source', ['coffeelint', 'index:source', 'karmaconfig', 'karma:continuous']
  grunt.registerTask 'compile', ['jshint', 'index:compile']
  grunt.registerTask 'build', ['ngmin', 'concat', 'uglify', 'index:build']

  # Get all scripts
  filterScripts = (files) ->
    files.filter (file) ->
      file.match /\.(js|coffee)$/

  # Get all styles
  filterStyles = (files) ->
    files.filter (file) ->
      file.match /\.(css|styl|less)$/

  # Build `index.html` by injecting all detected Java-/CoffeeScript and
  # CSS/Stylus/LESS files in target directory
  grunt.registerMultiTask 'index', 'Building `index.html`', ->
    # Extract the middle part (without the base (source, compile, or build)
    # directory and the extension
    extractRE = new RegExp '^[^/]+/(.+)\\..+$'

    # Iterate through all script and style files
    scripts = filterScripts(@filesSrc).map (file) ->
      file.replace extractRE, '$1.js'
    styles = filterStyles(@filesSrc).map (file) ->
      file.replace extractRE, '$1.css'

    # Copy over the entry point and compile references to the scripts and styles
    grunt.file.copy 'index.html', @data.dir + '/_layout.ejs',
      process: (contents, path) ->
        grunt.template.process contents,
          data:
            scripts: scripts
            styles: styles
            version: grunt.config 'pkg.version'
            yield: '<%= yield %>'

  ###
  # TODO review
  In order to avoid having to specify manually the files needed for karma to
  run, we use grunt to manage the list for us. The `karma/*` files are
  compiled as grunt templates for use by Karma. Yay!
  ###
  grunt.registerMultiTask 'karmaconfig', 'Process karma config templates', ->
    jsFiles = filterForJS(@filesSrc)
    grunt.file.copy 'karma/karma-unit.tpl.js', grunt.config('build_dir') + '/karma-unit.js',
      process: (contents, path) ->
        grunt.template.process contents,
          data:
            scripts: jsFiles
