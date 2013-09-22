request = require 'supertest'
chai = require 'chai'
expect = chai.expect
app = require '..'
models = require '../models/all'

describe 'Instructor', () ->
    describe 'login', () ->
        # it 'with an instructor account', (done) ->
        #     user = {username: 'sirhcwolf', password: 'yesiamaknight'}
        #     request(app).post('/').send(user).expect(302).end(done)

    describe 'identified', () ->
        it 'as an instructor', (done) ->
            expect(false).to.be.true
            done()

    describe 'creates a', () ->
        it 'course', (done) ->
            models.Course.create {name: 'SWENG 500'}, (err, c) ->
                expect(err).to.be.null
                expect(c.name).to.be.equal('SWENG 500')
                c.destroy done

        it 'forum', (done) ->
            expect(false).to.be.true
            done()

        it 'syllabus', (done) ->
            models.Course.create {name: 'SWENG 500'}, (err, c) ->
                expect(err).to.be.null
                expect(c.name).to.be.equal('SWENG 500')
                models.Syllabus.create {title: 'Welcome to SWENG 500', course: c}, (err, s) ->
                    expect(err).to.be.null
                    expect(s.title).to.be.equal('Welcome to SWENG 500')
                    expect(s.course.id).to.be.equal(c.id)
                    expect(s.createdOn).to.not.be.null
                    s.destroy () ->
                        c.destroy done

    describe 'uploads a', () ->
        it 'syllabus', (done) ->
            expect(false).to.be.true
            done()

    describe 'create a course with', () ->
        it 'an invalid date', (done) ->
            expect(false).to.be.true
            done()

        it 'a future access date', (done) ->
            expect(false).to.be.true
            done()

    describe 'uses a forum to', () ->
        it 'create a new post', (done) ->
            expect(false).to.be.true
            done()

        it 'upload an attachment to a new post', (done) ->
            expect(false).to.be.true
            done()

        it 'reply to an existing post', (done) ->
            expect(false).to.be.true
            done()

        it 'edit their own post', (done) ->
            expect(false).to.be.true
            done()
