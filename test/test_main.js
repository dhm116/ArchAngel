var tests = [];
for (var file in window.__karma__.files) {
  if (window.__karma__.files.hasOwnProperty(file)) {
    if (/Spec\.js$/.test(file)) {
      tests.push(file);
    }
  }
}

requirejs.config({
    //urlArgs: (new Date()).getTime(),
    // Karma serves files from '/base'
    baseUrl: 'base/mimosa-app/assets/javascripts' /*../mimosa-app/assets/javascripts'*/,
/*
    paths: {
        'jquery': 'vendor/jquery/jquery',
        'angular': 'vendor/angular/angular',
        'angular-cookies': 'vendor/angular-cookies/angular-cookies',
        'angular-mocks': 'vendor/angular-mocks/angular-mocks',
        'angular-resource': 'vendor/angular-resource/angular-resource',
        'angular-route': 'vendor/angular-route/angular-route',
        'flowtype': 'vendor/flowtype/flowtype',
        'foundation': 'vendor/foundation/foundation',
        'keypress': 'vendor/keypress/keypress',
        'ngstorage': 'vendor/ngstorage/ngStorage',
        'ratchet': 'vendor/ratchet/ratchet',
        'restangular': 'vendor/restangular/restangular',
        'underscore': 'vendor/underscore/underscore',
        'templates': '../../public/javascripts/templates',
        'courseService': 'app/course/services',
        'courseController': 'app/course/controllers',
        'loginService': 'app/login/services',
        'loginController': 'app/login/controllers',    

        'app': '../../public/javascripts/main'

    },

    shim: {
        'underscore': { exports: '_' },
        'angular-mocks': { deps: ['angular'], exports: 'AngularMocks'},
//        'app': { deps: ['angular-mocks', 'courseService', 'courseController', 
//                        'loginService', 'loginController'], exports: 'App'},
//        'courseService': { deps: ['angular-mocks'], exports: 'courseService'}
    },
*/
    // ask Require.js to load these files (all our tests)
    deps: tests,

    // start test run, once Require.js is done
    callback: window.__karma__.start
});