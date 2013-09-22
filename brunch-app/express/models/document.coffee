Schema = require('jugglingdb').Schema

Document = {
    title: String
    author: String
    createdOn: {type: Date, default: () -> new Date }
    content: Schema.Text
}

module.exports = Document