_ = require 'lodash'

module.exports = (grunt) ->
  ################################
  ## USER SETTINGS - EDIT BELOW ##
  ################################

  # Self-managed references for third-party files. These are either relative to
  # project root or HTTP(S) addresses
  vendorFiles =
    scripts:
      # Local files: relative to where Bower components are installed
      local: [
        'angular-bootstrap/ui-bootstrap.js'
        'angular-mocks/angular-mocks.js'
        'angular-ui-router/release/angular-ui-router.js'
        'angular-ui-utils/modules/route/route.js'
      ]
      # Remote files: absolute HTTP(S) URLs
      remote: [
        'https://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js'
        'https://netdna.bootstrapcdn.com/bootstrap/3.0.0/js/bootstrap.min.js'
        'https://ajax.googleapis.com/ajax/libs/angularjs/1.0.7/angular.min.js'
        # Recommended libraries
        #'https://cdnjs.cloudflare.com/ajax/libs/lodash.js/2.2.1/lodash.min.js'
        #'https://cdnjs.cloudflare.com/ajax/libs/restangular/0.5.1/dependencies/angular-resource.min.js'
        #'https://cdnjs.cloudflare.com/ajax/libs/restangular/0.5.1/restangular.min.js'
      ]
    styles:
      local: []
      remote: [
        "https://netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css"
        "https://netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.css"
      ]

  ################################
  ## DO NOT EDIT ANYTHING BELOW ##
  ################################

  # Paths
  sourceDir = 'app' # Where the source lives
  compileDir = 'build' # Where pre-processed and minified (except JS) code lives
  buildDir = 'public' # Where fully minified and concatenated output code lives
  configDir = 'etc' # Where to put config files
  vendorDir = 'bower_components' # Where the package-managed vendor files are
  tempDir = 'tmp' # Where the temporary build files live
  entryFilename = 'main' # Module definition must happen here

  # Load Grunt tasks
  grunt.loadNpmTasks 'grunt-contrib-jshint'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-conventional-changelog'
  grunt.loadNpmTasks 'grunt-bump'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-karma'
  grunt.loadNpmTasks 'grunt-ngmin'
  grunt.loadNpmTasks 'grunt-exec'
  grunt.loadNpmTasks 'grunt-concurrent'

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
        # Non-script/style assets
        assets: ["**/*.!(js|css|spec)"]
      compile:
        js: ["#{compileDir}/**/*.js", "!#{compileDir}/**/*.spec.js"]
        jsTest: ["!#{compileDir}/**/*.spec.js"]
        css: ["#{compileDir}/**/*.css"]

    # Metadata like the banner to be inserted above released source code
    meta:
      banner: '/**\n' + ' * <%= pkg.name %> - v<%= pkg.version %> - <%= grunt.template.today(\'yyyy-mm-dd\') %>\n' + ' * <%= pkg.homepage %>\n' + ' *\n' + ' * Copyright (c) <%= grunt.template.today(\'yyyy\') %> <%= pkg.author %>\n' + ' * Licensed <%= pkg.licenses.type %> <<%= pkg.licenses.url %>>\n' + ' */\n'

    # Automatic changelog
    changelog:
      options:
        dest: 'CHANGELOG.md'
        template: 'etc/changelog.tpl'

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

    # Clean house
    clean:
      source: ["#{sourceDir}/vendor"]
      compile: ["#{compileDir}/vendor"]
      build: [buildDir, tempDir]
      all: [compileDir, buildDir, tempDir, "#{sourceDir}/_#{entryFilename}.ejs"]

    ## Watch for development

    watch:
      options:
        atBegin: true
        livereload: true
      source:
        files: ["Gruntfile.coffee", "#{sourceDir}/**/*", "!#{sourceDir}/_#{entryFilename}.ejs", "!#{sourceDir}/vendor/**/*"]
        tasks: ['source']

    ## Concurrently run watch and server

    concurrent:
      options:
        logConcurrentOutput: true
      develop:
        tasks: ['watch', 'exec:harpServer']

    ## Build-related tasks

    # First prepare for minification
    ngmin:
      build:
        files: [
          src: ['<%= files.compile.js %>']
          expand: true
        ]

    # Then concatenate all JS and CSS files into respective release files
    concat:
      options:
        banner: '<%= meta.banner %>'

      scripts:
        src: [
          '<%= files.vendor.scripts.local %>'
          "#{configDir}/module_prefix.js"
          '<%= files.compile.js %>'
          "#{configDir}/module_suffix.js"
        ]
        dest: "#{buildDir}/vendor/<%= pkg.name %>-<%= pkg.version %>.min.js"

      styles:
        src: [
          '<%= files.compile.css %>'
        ]
        dest: "#{buildDir}/vendor/<%= pkg.name %>-<%= pkg.version %>.min.css"

    # Finally uglify the JS release file
    uglify:
      options:
        banner: '<%= meta.banner %>'
      compile:
        files:
          '<%= concat.scripts.dest %>': '<%= concat.scripts.dest %>'

    ## Style police

    jshint:
      options:
        curly: true
        immed: true
        newcap: true
        noarg: true
        sub: true
        boss: true
        eqnull: true
      src: '<%= files.compile.js %>'
      test: '<%= files.compile.jsTest %>'

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

    ## Build `404.html` to include references to all JS and CSS files

    copy:
      # Copy over local vendor files
      vendorToSource:
        expand: true
        flatten: true
        cwd: vendorDir
        src: ['<%= files.vendor.scripts.local %>']
        dest: "#{sourceDir}/vendor/"
      # Same for compiling
      vendorToCompile:
        expand: true
        flatten: true
        cwd: vendorDir
        src: ['<%= files.vendor.scripts.local %>']
        dest: "#{compileDir}/vendor/"
      # Copy over the assets from compile to build
      assetsToBuild:
        expand: true
        cwd: compileDir
        src: '<%= files.source.assets %>'
        dest: buildDir
      # Copy the built assets as vendor files to source
      buildToSource:
        expand: true
        cwd: "#{buildDir}/vendor"
        src: '*'
        dest: "#{sourceDir}/vendor"
      # Copy over from compile directory for building
      buildEntry:
        src: "#{tempDir}/404.html"
        dest: "#{buildDir}/404.html"

    # Actually building `404.html`
    entry:
      source:
        dir: sourceDir
        src: [
          '<%= files.source.js %>'
          '<%= files.source.coffee %>'
          '<%= files.source.css %>'
        ]

    ## Execute arbitrary commands

    exec:
      # Install Bower components
      bower:
        cmd: 'node_modules/.bin/bower install'
      # Run Harp server
      harpServer:
        cmd: "node_modules/.bin/harp server #{sourceDir}"
      # Compile code using Harp
      harpCompile:
        cmd: "node_modules/.bin/harp compile #{sourceDir} #{compileDir}"
      # Compile into a temporary directory pre-build. We need this to recompile
      # the `404.html` with references to the concatenated scripts
      harpBuild:
        cmd: "node_modules/.bin/harp compile #{sourceDir} #{tempDir}"
      # Kill the harp server and force exit peacefully no matter what
      harpKill:
        cmd: 'bash etc/kill_harp.sh'

  # Get all scripts
  filterScripts = (files) ->
    files.filter (file) ->
      file.match /\.(js|coffee)$/

  # Get all styles
  filterStyles = (files) ->
    files.filter (file) ->
      file.match /\.(css|styl|less)$/

  # Build `404.html` by injecting all detected Java-/CoffeeScript and
  # CSS/Stylus/LESS files in target directory
  grunt.registerMultiTask 'entry', 'Building `404.html`', (match) ->
    # Extract the middle part (without the base (source, compile, or build)
    # directory and the extension
    extractRE = new RegExp '^[^/]+/(.+)\\..+$'

    # Iterate through all script and style files
    scripts = filterScripts(@filesSrc).map (file) ->
      file.replace extractRE, '$1.js'
    styles = filterStyles(@filesSrc).map (file) ->
      file.replace extractRE, '$1.css'

    # Always put `main` script first
    _.remove scripts, (script) -> script is "#{entryFilename}.js"
    scripts.unshift "#{entryFilename}.js"

    # Filter out for only vendor script/style
    if match
      scripts = scripts.filter (script) ->
        script.match match
      styles = styles.filter (style) ->
        style.match match

    # Add remote vendor files to the *beginning* as external libraries take
    # precedence
    scripts.unshift remote for remote in vendorFiles.scripts.remote.reverse()

    # Do the same for styles
    styles.unshift remote for remote in vendorFiles.styles.remote.reverse()

    # Use non-EJS syntax to insert `yield`
    grunt.template.addDelimiters 'percentage', '{%', '%}'

    # Copy over the entry point and compile references to the scripts and styles
    grunt.file.copy 'etc/404.tpl.html', "#{@data.dir}/_#{entryFilename}.ejs",
      process: (contents, path) ->
        grunt.template.process contents,
          delimiters: 'percentage'
          data:
            scripts: scripts
            styles: styles
            version: grunt.config 'pkg.version'
            yield: '<%- yield %>'

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

  ## Build tasks

  # Usually you just want to run `grunt` to enter development mode
  grunt.registerTask 'default', ['exec:bower', 'exec:harpKill', 'concurrent:develop']
  # Or deploy it
  grunt.registerTask 'deploy', ['exec:bower', 'source', 'compile', 'build']

  # TODO include karma in development in `watch`
  #grunt.registerTask 'source', ['karmaconfig', 'karma:continuous']

  # Make sure our HTML is referencing all our scripts and styles
  grunt.registerTask 'source', [
    'clean:source' # Clean the source directory first
    'coffeelint' # Then check CoffeeScripts are style-compliant
    'copy:vendorToSource' # Copy over the vendor files
    'entry:source' # Build `404.html`
  ]

  # Compile for delivery (but not minified)
  grunt.registerTask 'compile', [
    'clean:compile' # Clean the compile directory
    'clean:source' # Clean the source directory as well because we need to compile from source
    'exec:harpCompile' # Because we're compiling from source
    'jshint' # Check JS compliance
    'copy:vendorToCompile' # Copy over vendor files
    'copy:vendorToSource' # Copy over vendor files back to source because of `clean:source`
  ]

  # The ultimate deployment package
  grunt.registerTask 'build', [
    # Clean up first
    'clean:build'

    # Then package the assets for deployment
    'ngmin:build' # Apply minification protection
    'concat' # Concatenate all files
    'uglify' # Uglify the files for production

    # We then need to compile the HTML with references to the packaged assets (only the script and the style)
    'clean:source' # Clean the source directory because we need to compile from source
    'copy:buildToSource' # Copy over the the built assets as vendor files to source
    'entry:source:^vendor' # Build the `404.html`
    'exec:harpBuild' # Compile the `404.html` to the temporary directory
    'copy:buildEntry' # Transfer only the built `404.html` over to the build directory
    'copy:assetsToBuild' # Copy assets to the build directory
  ]
