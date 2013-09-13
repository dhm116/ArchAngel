request = require 'supertest'
chai = require 'chai'
expect = chai.expect
app = require '..'

describe 'GET /', () ->
    it 'respond with 200', (done) ->
        request(app)
            .get('/')
            .expect(200, done)

describe 'GET /test', () ->
    it 'respond with 200', (done) ->
        request(app)
            .get('/test')
            .expect(200, done)

describe 'GET /error', () ->
    it 'respond with 404', (done) ->
        request(app)
            .get('/error')
            .expect(404, done)

describe 'Instructors should be able to login', () ->
    it 'should log in with a instructor account', (done) ->
        user = {username: 'sirhcwolf', password: 'yesiamaknight'}
        request(app).post('/').send(user).expect(302).end(done)

# describe 'Instructors should be able to upload a syllabus', () ->
#     it 'should accept a file upload and generate a syllabus', (done) ->
#         request(app).post('/submitsyllabus').attach('afile', 'config.coffee').expect(200, done)
