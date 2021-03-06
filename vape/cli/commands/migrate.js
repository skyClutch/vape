const fs      = require('fs')
const fwf     = require('fun_with_flags')
const pg      = require('pg')
const migrate = require('pgmigrate')
const pgConnectionString = require('pg-connection-string')
const path = require('path')
const config = require(path.resolve('./config/server'))

module.exports = {
  add: {
    description: '<name> - create migration file with timestamp',

    exec: function (target, name) {
      let filepath = `schema/${new Date().toISOString()}-${name}.sql`
      fs.writeFileSync(filepath, '')
      return filepath
    }
  },

  run: {
    description: 'runs migrations',

    exec: function (target, isSync) {

      let promise = Promise.resolve()

      if (target.drop !== undefined) {
        promise = fwf.shell(`psql ${config.PSQL_ADMIN_URI} -c 'drop table public.schema_info cascade; drop schema ${config.PSQL_SCHEMA} cascade; drop schema ${config.PSQL_SCHEMA}_private cascade;'`)
      }

      return promise
      .then(() => {
        return fwf.shell(`psql ${config.PSQL_ADMIN_URI} -c "drop role if exists ${config.PSQL_SCHEMA}_postgraphql; create role ${config.PSQL_SCHEMA}_postgraphql login password '${config.APP_PASSWORD}';"`) 
      })
      .then(function () {
        return fwf.shell('./node_modules/.bin/migrate', [], {
          env: Object.assign({}, process.env, {
            DATABASE_URL: config.PSQL_ADMIN_URI
          })
        })
      })
    },

    options: {
      drop: {
        description: 'drops everything and starts over'
      }
    }
  }
}
