request = require 'supertest'
chai = require 'chai'
expect = chai.expect
app = require '..'

describe 'Instructor', () ->
    describe 'login', () ->
        it 'with an instructor account', (done) ->
            user = {username: 'sirhcwolf', password: 'yesiamaknight'}
            request(app).post('/').send(user).expect(302).end(done)

    describe 'identified', () ->
        it 'as an instructor', (done) ->
            expect(false).to.be.true
            done()

    describe 'creates a', () ->
        it 'course', (done) ->
            {Course, Syllabus} = require('../models/syllabus')
            Course.create {name: 'SWENG 500'}, (err, c) ->
                expect(err).to.be.null
                expect(c.name).to.be.equal('SWENG 500')
                c.destroy done

            # expect(false).to.be.true
            # done()

        it 'forum', (done) ->
            expect(false).to.be.true
            done()

        it 'syllabus', (done) ->
            expect(false).to.be.true
            done()

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
