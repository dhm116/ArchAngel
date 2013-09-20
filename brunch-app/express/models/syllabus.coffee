crypto = require 'crypto'

md5 = crypto.createHash 'md5'
pw = md5.update('archangel').digest('hex')

Schema = require('jugglingdb').Schema
# schema = new Schema('redis', {port:6379})
schema = new Schema 'postgres', {
    database: 'archangel'
    username: 'archangel'
}

Syllabus = schema.define 'Syllabus', {
    title: String
}

Course = schema.define 'Course', {
    name:
        type: String
        index: true
    syllabus: Syllabus
}

Syllabus.belongsTo('course')

schema.automigrate()

module.exports.schema = schema
module.exports.Course = Course
module.exports.Syllabus = Syllabus