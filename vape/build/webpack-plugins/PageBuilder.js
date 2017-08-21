const withPgClient = require('../../util/postgres/withPgClient')
const config       = require('../../../config/server')
const templates    = require('../../../templates')

function PageBuilder ({ hook }) {
  this.hook = hook || 'run' // lets us set the hook to watch-run for dev mode
}

PageBuilder.prototype.apply = function (compiler) {
  compiler.plugin(this.hook, (compilationParams, callback) => {
    return withPgClient(client => {
      // get pages
      return client.query(`select * from ${config.PSQL_SCHEMA}.page;`)

      // create pages that don't exist
      .then(result => {
        const names = result.rows.map(row => row.template)

        let insert = `insert into ${config.PSQL_SCHEMA}.page (route, name, template, data) `
        let values = []

        Object.values(templates.default).forEach(template => {
          if (names.indexOf(template.name) === -1)
            values.push(`('${template.route || '/' + template.name}', '${template.name}', '${template.name}', '{}')`)
        })

          console.log(`${insert} values ${values.join(',')};`)

        if (values.length)
          return client.query(`${insert} values ${values.join(',')};`)
        return null
      })

      // move on
      .then(() => {
        callback()
      })

      // catch error, log, and move on
      .catch(err => {
        console.error(err)
        callback()
      })
    }, false)
  })
}

module.exports = PageBuilder
