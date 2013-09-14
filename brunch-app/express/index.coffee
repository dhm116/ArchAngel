express = require 'express'
{join} = require 'path'
{config} = require './config'
routes = require './routes'
request = require 'request-json'

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

app.configure 'development', ->
    app.use express.errorHandler()
    app.locals.pretty = true

app.all '*', (req, res, next) =>

    unless req.session.user
        randomuserme.get '/?results=10', (err, result, body) =>
            if err
                console.log err
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
app.get '/test', routes.test('Mocha Tests')
app.get '/main', (req, res, next) =>
    res.render 'main', {title: 'Penn State ArchAngel Course Management System', courses:['SWENG 500', 'SWENG 505']}

app.post '/', (req, res, next) =>
    res.redirect '/main'

### Default 404 middleware ###
app.use routes.error('Page not found :(', 404)

module.exports = exports = app