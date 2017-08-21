const pgPool = require('./pgPool')

/**
 * calls a callback with a pg client context
 * wraps in a transaction and rolls back if in test mode
 * @param {function} cb - callback to pass client context to
 * @param {boolean} isTest - test flag, default true
 * @returns {promise}
 */
function withPgClient(cb, isTest = true) {
  let client

  // connect
  return pgPool.connect()

  // wrap in transaction to be rolled back if test or error
  .then(c => {
    client = c
    return client.query('begin')
  })

  // call callback -- should be a promise
  .then(() => {
    return cb(client)
  })

  // commit or rollback depending on context
  .then(() => {
    if (isTest)
      return client.query('rollback')
    return client.query('commit')
  })

  // release
  .then(() => {
    return client.release()
  })

  // make sure we rollback if an error occurs
  .catch(err => {
    console.error(err)
    if (isTest)
      return client.query('rollback').then(() => client.release())
    return null
  })
}

module.exports = withPgClient
