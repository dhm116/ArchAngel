// Karma configuration
// Generated on Tue Nov 05 2013 16:17:09 GMT-0800 (PST)

module.exports = function(config) {
  config.set({

    // base path, that will be used to resolve files and exclude
    basePath: '..',


    // frameworks to use
    frameworks: ['jasmine', 'requirejs'],


    // list of files / patterns to load in the browser
    files: [
      {pattern: 'mimosa-app/assets/javascripts/app/*.coffee', included: false},
      {pattern: 'mimosa-app/assets/javascripts/app/**/*.coffee', included: false},
      {pattern: 'mimosa-app/assets/javascripts/vendor/**/*.js', included: false},
      {pattern: 'test/**/*Spec.js', included: false},
      'test/test_main.js'
    ],


    // list of files to exclude
    exclude: [
      'mimosa-app/assets/javascripts/main.coffee'
    ],


    // test results reporter to use
    // possible values: 'dots', 'progress', 'junit', 'growl', 'coverage'
    reporters: ['progress', 'html'],

    htmlReporter: {
        outputDir: '../test/karma_html',
        templatePath: '../test/karma_html/jasmine_template.html'
    },


    // web server port
    port: 9877,


    // enable / disable colors in the output (reporters and logs)
    colors: true,


    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,


    // Start these browsers, currently available:
    // - Chrome
    // - ChromeCanary
    // - Firefox
    // - Opera (has to be installed with `npm install karma-opera-launcher`)
    // - Safari (only Mac; has to be installed with `npm install karma-safari-launcher`)
    // - PhantomJS
    // - IE (only Windows; has to be installed with `npm install karma-ie-launcher`)
    browsers: ['Chrome'],


    // If browser does not capture in given timeout [ms], kill it
    captureTimeout: 60000,


    // Continuous Integration mode
    // if true, it capture browsers, run tests and exit
    singleRun: false,

    preprocessors: {
      '**/*.coffee': 'coffee'
    },

  });
};
