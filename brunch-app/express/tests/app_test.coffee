request = require 'supertest'
chai = require 'chai'
expect = chai.expect
app = require '..'
{Course, Syllabus} = require('../models/syllabus')

describe 'User interface tests', () ->
    describe 'GET', () ->
        it '/ respond with 200', (done) ->
            request(app)
                .get('/')
                .expect(200, done)
        it '/test respond with 200', (done) ->
            request(app)
                .get('/test')
                .expect(200, done)

        it '/error respond with 404', (done) ->
            request(app)
                .get('/error')
                .expect(404, done)

        it '/courses responds with 200 ', (done) ->
            request(app)
                .get('/courses.json')
                .expect(200, done)

        it '/courses responds with a list of courses', (done) ->
            request(app)
                .get('/courses.json')
                .end (err, res) ->
                    expect(res.text).to.exist
                    data = JSON.parse(res.text)
                    Course.all (err, courses) ->
                        expect(data.length).to.equal(courses.length)
                        done()

    describe 'POST', () ->

        it 'creates a course', (done) ->
            request(app)
                .post('/courses')
                .send({name: 'POST Test Course'})
                .end (err, res) ->
                    expect(err).to.be.null
                    expect(res.text).to.exist
                    data = JSON.parse(res.text)
                    Course.find data.id, (err, c) ->
                        expect(err).to.be.null
                        c.destroy done

