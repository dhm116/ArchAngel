log = require '../lib/logger'
{config} = require '../config'

Schema = require('jugglingdb').Schema

unless config.db?.type?
    schema = new Schema 'memory'
else
    log.info "Connecting to #{config.db.type}"
    schema = new Schema config.db.type, config.db.options

module.exports = schema