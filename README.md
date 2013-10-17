# Harp Boilerplate for Angular.js <br/>[![Dependency Status](https://david-dm.org/kenhkan/hb-angular.png)](https://david-dm.org/kenhkan/hb-angular) [![Stories in Ready](https://badge.waffle.io/kenhkan/hb-angular.png)](http://waffle.io/kenhkan/hb-angular)

Merging best practices in Angular.js and Harp for a build process that anyone
can understand. This boilerplate is created out of frustration in making
[ngBoilerplate](https://github.com/ngbp/ng-boilerplate) work with file types
that it does not support.

ngBoilerplate is a great starting point for Angular.js projects and this
boilerplate takes many ideas from ngBoilerplate too. With Harp added to the pot
though, there is no configuration to make sure everything works!

It also has an extremely bare file structure convention. You only need to stay
away the `vendor` directory of the `_entry.ejs` index template file. Everything
else works as expected! Or your money back! (Just in case: you are not paying
me anything, but do send in pull requests or issues if it doesn't work for you.)


## Installation

1. `npm install -g grunt`
2. `git clone https://github.com/kenhkan/hb-angular.git`
3. `npm install`


## Usage

Rule of thumb:

1. Run `grunt watch` to rebuild the references on file change
2. Run `grunt server` to run the Harp server
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
    etc/404.tpl.html -> The template for building 404.html
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

Remember to edit `etc/404.tpl.html` to set the `ng-app` and top-level
`ng-controller` for your app!

### Layout

Harp provides a powerful layout mechanism with `_layout`. However, do *not* use
Harp's layout mechanism as `_layout` is automatically generated with the
correct references to your scripts and styles.

### App file structure

There is no convention here. Scripts and styles recognized by Harp are compiled
and automatically included when `grunt watch` is run. Anything else (including
markups) is treated as assets and are transferred as-is for your deployment.

The file `_main.ejs` is automatically managed to include references to
compiled scripts and styles. Do *not* save a user markup file to that filename.
This is a layout file that is automatically applied on the `404.html` file.

The directory `vendor/` is reserved for third-party code that is managed by
Bower. Your app directory could look something like:

    src/vendor -> Reserved for third-party code
    src/_main.ejs -> Automatically managed
    src/404.jade -> Entry point
    src/partials/login.jade -> A partial included either by Harp partial
      mechanism or by Angular.js' ui-route. It is copied on compilation if not
      hidden.
    src/images/logo.png -> This is automatically copied on compilation if not
      hidden.
    ...

### `main`

The file `main.js` is always included in the `<HEAD>` first. You should always
initialize your module there. `app.js` is by convention there to house the
controller code for `AppController`, which is declared at `<HTML>`.

### HTML5 Mode

There is notably no index page but a 404 page. Modern webservers should always
return `/404.html` without showing it as such (i.e. no redirection). This plays
nicely with Angular.js' HTML5 which requires all requests to non-existing path
to return the application page. Do not name any file `index` to avoid the
webserver serving sub-views. See Angular.js' [HTML
mode](http://docs.angularjs.org/guide/dev_guide.services.$location)
