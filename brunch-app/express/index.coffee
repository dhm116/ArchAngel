express = require 'express'
{join} = require 'path'
{config} = require './config'
routes = require './routes'
request = require 'request-json'
log = require './lib/logger'
path = require 'path'
underscore = require 'underscore'
resource = require 'express-resource'
rj = require 'resource-juggling'
models = require './models/syllabus'

randomuserme = request.newClient 'http://api.randomuser.me/'

app = express()

app.configure 'production', ->
    app.use express.limit '5mb'

app.configure ->
    app.set 'views', join __dirname, 'views'
    app.set 'view engine', config.view.engine
    app.use express.favicon()
    app.use express.logger 'dev'
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use express.compress()
    app.use express.cookieParser(config.cookie.secret)
    app.use express.session()
    # app.use express.csrf()
    app.use app.router
    app.use express.static join __dirname, '..', 'public'
    #app.engine 'html', config.view.engine

app.configure 'development', ->
    app.use express.errorHandler()
    app.locals.pretty = true

app.all '*', (req, res, next) =>
    res.locals.title = 'Penn State ArchAngel Course Management System'
    res.locals.courses = ['SWENG 500', 'SWENG 505']
    res.locals._ = underscore

    unless req.session.user
        randomuserme.get '/?results=10', (err, result, body) =>
            if err
                log.error err
            else
                req.session.user  = body.results[0].user
                res.locals.user = req.session.user
                req.session.people  = (result.user for result in body.results[1..])
                res.locals.people = req.session.people
            next()
    else
        res.locals.user = req.session.user
        res.locals.people = req.session.people
        next()

app.get '/', routes.index('Penn State ArchAngel Course Management System', express.version)

app.get '/tests', (req, res, next) =>
    exec = require('child_process').exec

    log.info 'Generating up-to-date JSON test report'

    child = exec 'mocha express/tests/*.coffee --compilers coffee:coffee-script --reporter `pwd`/json2.js', (err, stdout, stderr) ->
        if stderr
            log.error err
            log.info stdout
            log.warn stderr

        res.render 'tests', {results: require('./tests/report.json')}

app.get '/test', routes.test('Mocha Tests')

app.get '/main', (req, res, next) =>
    res.render 'main'

app.post '/', (req, res, next) =>
    res.redirect '/main'

models.Course.all (err, courses) ->
    unless courses.length
        models.Course.create {name: 'Default course'}, (err, c) ->
            # c.syllabus.create {name: 'Default syllabus'}, (err, s) ->
            #     console.log 'Finished creating default course and syllabus'

courses = app.resource 'courses', rj.getResource
    schema: models.schema
    name: 'Course'
    model: models.Course

syllabus = app.resource 'syllabus', rj.getResource
    schema: models.schema
    name: 'Syllabus'
    model: models.Syllabus
    collection: (request) ->
        request.Course.syllabus
    addPlaceholderForEmpty: true

courses.add syllabus

### Default 404 middleware ###
app.use routes.error('Page not found :(', 404)

module.exports = exports = app