schema = require './schema'

Profile = schema.define 'Profile', {
    picture: String
}

User = schema.define 'User', {
    title: String
    firstName: String
    lastName: String
    email: String
    userid: String
    profile: Profile
}

Profile.belongsTo 'User'

schema.autoupdate()

module.exports.User = User
module.exports.Profile = Profile