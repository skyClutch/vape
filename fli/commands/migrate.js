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
      var args = []

      if (isSync)
        args = ['--sync']

      return fwf.shell('psql', ['vape', '-c', 'drop schema public cascade; create schema public'])
      .then(function () {
        return fwf.shell('./node_modules/.bin/migrate', args, {
          env: Object.assign({}, process.env, {
            DATABASE_URL: config.PSQL_ADMIN_URI
          })
        })
      })
    }
  }
}
