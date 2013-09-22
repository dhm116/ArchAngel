express = require 'express'
{join} = require 'path'
{config} = require './config'
routes = require './routes'
request = require 'request-json'
log = require './lib/logger'
path = require 'path'
underscore = require 'underscore'
resource = require 'express-resource'
flash = require 'connect-flash'
passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
RedisStore = require('connect-redis')(express)

rj = require 'resource-juggling'
models = require './models/all'

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
    app.use express.session {
        store: new RedisStore {
            host: 'localhost'
            port: 6379
            db: 2
        }
        secret: 'asdl;fkj123049uq0-[9sdajks;df'
    }
    app.use flash()
    app.use passport.initialize()
    app.use passport.session()
    # app.use express.csrf()
    app.use app.router
    app.use express.static join __dirname, '..', 'public'
    #app.engine 'html', config.view.engine

users = []
models.User.all (err, results) ->
    users = results

#everyauth.helpExpress(app)
models.User.count (err, count) ->
    unless count >= 20
        randomuserme.get '/?results=5', (err, result, body) =>
            log.info "Finished retrieving #{body.results.length} users"
            randomUsers = (row.user for row in body.results)
            for user, index in randomUsers
                user.id = user.email.split("@")[0]
                models.User.create {
                    title: user.name.title
                    firstName: user.name.first
                    lastName: user.name.last
                    email: user.email
                    userid: user.id
                    profile: {picture: user.picture}
                }, (err, u) ->
                    u.profile.UserId = u.id
                    u.profile.save () ->
                        users.push u

app.configure 'development', ->
    app.use express.errorHandler()
    app.locals.pretty = true

getUserByUserId = (userid) ->
    user = underscore.find users, (u) -> u.userid == userid

passport.use new LocalStrategy {usernameField: 'userid'}, (userid, password, done) ->
    user = getUserByUserId(userid)
    unless user
        done(null, false, {message: "No user with userid #{userid} found"})
    else
        # TODO: Verify the password
        done(null, user)

passport.serializeUser (user, done) ->
    done(null, user.userid)

passport.deserializeUser (userid, done) ->
    user = getUserByUserId(userid)
    done(null, user)

app.all '*', (req, res, next) =>
    res.locals.title = 'Penn State ArchAngel Course Management System'
    res.locals.courses = ['SWENG 500', 'SWENG 505']
    res.locals._ = underscore

    res.locals.user = req.user
    # unless req.session.user
    #             req.session.user  = users[0].user
    #             res.locals.user = req.session.user
    #             req.session.people  = (result.user for result in body.results[1..])
    #             res.locals.people = req.session.people
    #         next()
    # else
    #     res.locals.user = req.session.user
    res.locals.people = users
    req.session.people = users
    next()

app.get '/tests', (req, res, next) =>
    exec = require('child_process').exec

    log.info 'Generating up-to-date JSON test report'

    child = exec 'mocha express/tests/*.coffee --compilers coffee:coffee-script --reporter `pwd`/json2.js', (err, stdout, stderr) ->
        if stderr
            log.error err
            log.warn stderr
        log.info stdout

        res.render 'tests', {results: require('./tests/report.json')}

app.get '/test', routes.test('Mocha Tests')

app.get '/', (req, res, next) =>
    if req.session.passport.user
        res.render 'index'
    else
        res.redirect '/login'

app.get '/login', (req, res, next) =>
    res.render 'login', {user: req.user || users[0], message: req.flash('error')}

app.post '/login', passport.authenticate('local', {successRedirect: '/', failureRedirect: '/login', failureFlash: true})

app.get '/logout', (req, res) ->
    req.logout()
    res.redirect '/'

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
    # collection: (request) ->
    #     request.Course.syllabus
    addPlaceholderForEmpty: true

# courses.add syllabus

### Default 404 middleware ###
app.use routes.error('Page not found :(', 404)

module.exports = exports = app