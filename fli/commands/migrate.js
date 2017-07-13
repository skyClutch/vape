const fs      = require('fs')
const fwf     = require('fun_with_flags')
const pg      = require('pg')
const migrate = require('pgmigrate')
const pgConnectionString = require('pg-connection-string')
const config = require('../../config')

module.exports = {
  add: {
    description: '<name> - create migration file with timestamp',

    exec: function (target, name) {
      var filepath = `schema/${new Date().toISOString()}-${name}.sql`
      fs.writeFileSync(filepath, '')
      return filepath
    }
  },

  run: {
    description: 'runs migrations',

    exec: function (target, isSync) {
      return fwf.shell(`DATABASE_URL=${config.PSQL_URI} ./node_modules/pgmigrate/cli.js`)
    }
  }
}
