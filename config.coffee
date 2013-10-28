exports.config =
  # See docs at http://brunch.readthedocs.org/en/latest/config.html.
  conventions:
    assets: /^app\/assets\//
  modules:
    definition: false
    wrapper: false
  paths:
    public: 'public'
    jadeCompileTrigger: '_jade_templates.js'
  files:
    javascripts:
      joinTo:
        'app.js': /^app\/(?!.+\.spec\.)/
        'vendor.js': /^(bower_components|vendor)/
      order:
        before: [
          'bower_components/lodash/lodash.js'
          'bower_components/jquery/jquery.js'
          'bower_components/angular/angular.js'
          'app/main.coffee'
        ]

    stylesheets:
      joinTo:
        'app.css': /^app/
        'vendor.css': /^(bower_components|vendor)/

    templates:
      joinTo:
        '_jade_templates.js': /^app/

  plugins:
    jade:
      pretty: true
    jade_angular:
      static_mask: /404.jade/
      single_file: true
      single_file_name: 'templates.js'
