schema = require './schema'

Syllabus = schema.define 'Syllabus', {
    title: String
}

schema.automigrate()

module.exports = Syllabus