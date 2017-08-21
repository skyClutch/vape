const Pool                    = require('pg').Pool
const parsePgConnectionString = require('pg-connection-string').parse
const config                  = require('../../../config/server')
const pgUrl                   = config.PSQL_ADMIN_URI

const pgPool = new Pool(Object.assign({}, parsePgConnectionString(pgUrl), {
  max: 15,
  idleTimeoutMillis: 500,
}))

module.exports = pgPool
