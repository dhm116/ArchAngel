schema = require './schema'

Document = schema.define 'Document', {
    title: String
    author: String
    createdOn: Date
}

schema.automigrate()

module.exports = Document