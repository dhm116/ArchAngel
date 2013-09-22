schema = require './schema'
Syllabus = require './syllabus'

Course = schema.define 'Course', {
    name:
        type: String
        index: true
    syllabus: Syllabus
}

Syllabus.belongsTo('course')

schema.autoupdate()

module.exports = Course