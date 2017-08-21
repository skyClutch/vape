const withPgClient = require('../withPgClient')
const config = require('../../../../config/server')

test('withPgClient should be able to connect and find the app schema', done => {
  withPgClient(client => {
    return client.query('select nspname from pg_catalog.pg_namespace;')
    .then(result => {
      let rows = result.rows.map(row => row.nspname)
      expect(rows.indexOf(config.PSQL_SCHEMA) > -1).toBe(true)
      done()
    })
  })
})
