
/**
 * Module dependencies.
 */
var fs = require('fs');
var util = require('util');
var mocha = require('mocha');
var Base = mocha.reporters.Base
  , utils = mocha.utils
  , cursor = Base.cursor
  , color = Base.color;

/**
 * Expose `JSON`.
 */

exports = module.exports = JSONReporter2;

/**
 * Initialize a new `JSON` reporter.
 *
 * @param {Runner} runner
 * @api public
 */

function JSONReporter2(runner) {
  var self = this;
  Base.call(this, runner);

  var tests = []
    , failures = []
    , passes = []
    , suites = [];

  runner.on('suite', function(suite) {
    if(suite.root) return;
    suites.push(utils.escape(suite.title));
  });

  runner.on('test end', function(test){
    tests.push(test);
  });

  runner.on('pass', function(test){
    passes.push(test);
  });

  runner.on('fail', function(test){
    failures.push(test);
  });

  runner.on('end', function(){
    var obj = {
        stats: self.stats
      , suites: suites
      , tests: tests.map(clean)
      , failures: failures.map(clean)
      , passes: passes.map(clean)
    };

    /**
     * Copying from https://github.com/ArtemisiaSolutions/mocha-json-file-reporter
     */
    var jsonOutput = JSON.stringify(obj, null, 2);
    process.stdout.write(jsonOutput);

    try {
      util.print("\nGenerating report.json file")
      var path = "./express/tests/";
      if(process.env.REPORT_PATH){
        path = process.env.REPORT_PATH
      }
      var out  = fs.openSync(path+"/report.json", "w");

      fs.writeSync(out, jsonOutput);
      fs.close(out);
      util.print("\nGenerating report.json file complete in "+path+"\n")
    } catch (error) {
      util.print("\nError: Unable to write to file report.json\n");
    }
  });
}

/**
 * Return a plain-object representation of `test`
 * free of cyclic properties etc.
 *
 * @param {Object} test
 * @return {Object}
 * @api private
 */

function clean(test) {
  return {
      title: test.title
    , fullTitle: test.fullTitle()
    , classname: test.parent.fullTitle()
    , duration: test.duration
  }
}