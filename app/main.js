// Fetch all files provided by Karma
var files = [];
for (var file in window.__karma__.files) {
  if (window.__karma__.files.hasOwnProperty(file)) {
    // We can simply use `.js` because Harp resolves file format differences
    // automatically
    file = file.replace(/\.coffee$/, '.js');
    // Only take application files
    if (!/(\/vendor\/|\/node_modules\/)/.test(file)) {
      // And not entry files
      if (!/(main|app)\.js$/.test(file)) {
        files.push(file);
      }
    }
  }
}

// Configure Require.js
requirejs.config({
  baseUrl: '/base/app',
  deps: [
    '/base/app/app.js'
  ],
  callback: function (){ return window.__karma__.start(); },
  paths: {
    'angular-mocks': 'vendor/angular-mocks/angular-mocks',
    'angular-resource': 'vendor/angular-resource/angular-resource',
    'angular-ui-router': 'vendor/angular-ui-router/release/angular-ui-router.min',
    'angular-ui-utils': 'vendor/angular-ui-utils/modules/utils',
    angular: 'vendor/angular/angular',
    bootstrap: 'vendor/bootstrap/dist/js/bootstrap',
    jquery: 'vendor/jquery/jquery',
    lodash: 'vendor/lodash/dist/lodash.compat',
    requirejs: 'vendor/requirejs/require',
    restangular: 'vendor/restangular/dist/restangular.min'
  }
});
