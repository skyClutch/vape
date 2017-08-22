const path           = require('path')
const withPgClient   = require('../../util/postgres/withPgClient')
const config         = require('../../../config/server')
const webpack        = require('webpack')
const MFS            = require('memory-fs')
const mfs            = new MFS()
const rfs            = require('require-from-string')
const templateConfig = require('../webpack.template.config.js')
const isTest         = process.env.NODE_ENV === 'test'

// drop compiled files into MFS
const templateCompiler = webpack(templateConfig)
templateCompiler.outputFileSystem = mfs

function PageBuilder ({ hook }) {
  this.hook = hook || 'run' // lets us set the hook to watch-run for dev mode
}

PageBuilder.prototype.apply = function (compiler) {
  compiler.plugin(this.hook, (compilationParams, callback) => {
    return new Promise((resolve, reject) => {
      // run webpack to compile templates
      templateCompiler.run((err, stats) => {
        let file = mfs.readFileSync(path.resolve(__dirname, '../../dist/templates.js'))
        let templates = rfs(file.toString())

        if (err)
          reject(err)
        else
          resolve(templates)
      })
    })
    .then(templates => {
      return withPgClient(client => {
        // get pages
        return client.query(`select * from ${config.PSQL_SCHEMA}.page;`)

        // create pages that don't exist
        .then(result => {
          const names = result.rows.map(row => row.template)

          let insert = `insert into ${config.PSQL_SCHEMA}.page (route, name, template, data) `
          let values = []

          Object.values(templates.default).forEach(template => {
            console.log(template)
            if (template.name && names.indexOf(template.name) === -1) {
              values.push(`('${template.route || '/' + template.name}', '${template.name}', '${template.name}', '{}')`)
              console.log(`Syncing template "${template.name}" with db...`);
            }
          })

          if (values.length)
            return client.query(`${insert} values ${values.join(',')};`)
          return null
        })

        // move on
        .then(() => {
          console.log('Templates Synced.');
          callback()
        })

        // catch error, log, and move on
        .catch(err => {
          console.error(err)
          callback()
        })
      }, isTest) // add flag to keep it from rolling back
    })
  })
}

module.exports = PageBuilder
