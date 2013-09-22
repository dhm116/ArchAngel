schema = require './schema'
Document = require './document'
_ = require 'underscore'

Syllabus = schema.define 'Syllabus', _.extend Document, {
    title: String
}

schema.autoupdate()

module.exports = Syllabus