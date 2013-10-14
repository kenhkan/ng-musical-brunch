# Harp Boilerplate for Angular.js <br/>[![Dependency Status](https://david-dm.org/kenhkan/hb-angular.png)](https://david-dm.org/kenhkan/hb-angular) [![Stories in Ready](https://badge.waffle.io/kenhkan/hb-angular.png)](http://waffle.io/kenhkan/hb-angular)


Merging best practices in Angular.js and Harp for a build process that anyone
can understand. This boilerplate is created out of frustration in making
[ngBoilerplate](https://github.com/ngbp/ng-boilerplate) work. ngBoilerplate is
a great starting point for Angular.js projects and this boilerplate takes many
ideas from ngBoilerplate too. With Harp added to the pot though, there is no
configuration to make sure everything works! This boilerplate is to make
Angular.js development a joy with Harp.


## Installation

1. `npm install -g grunt`
2. `git clone https://github.com/kenhkan/hb-angular.git`
3. `npm install`


## Usage

Rule of thumb:

1. Run `grunt watch`
2. Run `grunt server`
3. Open `localhost:9000` in your browser

### `grunt`

Compile and build the project. Output code is put in `build/`. See [file
structure](#file-structure) for more information.

### `grunt watch`

Watch for file changes and automatically recompile

### `grunt server`

Run the Harp server for development

### `grunt clean`

This resets the project to its pristine state.

### Utilities

* [Changelog building](https://github.com/btford/grunt-conventional-changelog) `grunt changelog`
* [Version bumping](https://github.com/vojtajina/grunt-bump) `grunt bump`


## File structure

After having set up the project, the file structure would look like:

    etc/changelog.tpl -> The template for building CHANGELOG.md
    etc/index.tpl.html -> The template for building index.html
    etc/module_prefix.js -> The enclosing code for compiled and minified code
    etc/module_suffix.js -> The ending counterpart of `module_prefix.js`
    src/ -> Anything specific to the app goes here
    bower.json -> Bower dependency declaration
    Gruntfile.coffee -> Gruntfile configuration
    package.json -> NPM dependency declaration
    README.md -> This document

After having run `grunt`, additional directories are added:

    bower_compoennts/ -> Downloaded Bower components
    build/ -> Production-ready code (compiled, minified, uglified, and concatenated)
    lib/ -> Deployment-ready code (compiled)
    node_modules/ -> Downloaded NPM modules
    tmp/ -> Temporary directory for building. Ignore


## Conventions and configuration

### Package management

Because developing in Angular.js requires many external libraries, package
management should be automated using [Bower](http://bower.io/). Follow these steps:

1. Find a package you want
2. Add to `bower.json`
3. Run `grunt install`
4. Add the specific file you want to include to `Gruntfile.coffee`, under
`vendorFiles.scripts.local` and `vendorFiles.styles.local` for JavaScript and
CSS files respectively

If you want to include CDN-hosted libraries, simply do step #4 except add the
URLs to `vendorFiles.scripts.remote` and `vendorFiles.styles.remote`.

### App settings

Remember to edit `etc/index.tpl.html` to set the `ng-app` and top-level
`ng-controller` for your app!

### Layout

Harp provides a powerful layout mechanism. However, in Angular.js, routing is
handled internally by the `$location` subsystem. So we only need one HTML
file--the `index.html`. Simply define a `index.html`, `index.jade`, or
`index.ejs` and use Harp's partials to include other parts of your app.

Also, do *not* use Harp's own `_layout` as it is automatically generated with
correct references to your scripts and styles.

### App file structure

There is no convention here. Any file recognized by Harp is compiled. Anything
else is treated as assets and are transferred as-is for your deployment.

The directory `vendor/` is reserved for third-party code that is managed by
Bower. Your app directory could look something like:

    src/vendor -> Reserved for third-party code
    src/_layout.ejs -> Automatically managed
    src/index.jade -> Entry point
    src/_partials/login.jade -> Include this in `index.jade` and do not serve
    src/images/logo.png -> This is automatically copied on compilation
    ...

### HTML5 Mode

There is notably no 404 or 500 pages. You should set your server to return the
`index.html` for all requests to the server. This is a requirement to leverage
Angular.js' [HTML
mode](http://docs.angularjs.org/guide/dev_guide.services.$location)
