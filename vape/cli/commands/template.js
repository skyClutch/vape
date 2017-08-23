const fs = require('fs')
const values = []
const fwf = require('fun_with_flags')
const path = require('path')
const config = require(path.resolve('./config/server'))

module.exports = {
  dump: {
    description: 'dumps current pages',

    exec(target) {
      return fwf.shell('pg_dump', [config.PSQL_ADMIN_URI, '-t', `${config.PSQL_SCHEMA}.page`, '-a', '--column-inserts'])
      .then(result => {
        return result.data.match(/INSERT.*/g).join('\n')
        .replace(/INSERT INTO page/g, `INSERT INTO ${config.PSQL_SCHEMA}.page`)
      })
      .then(insert => {
        return new Promise((res, rej) => {
          fs.writeFile('schema/2017-07-14T06:48:57.618Z-page-seed-data.sql', insert, (err) => {
            if (err)
              return rej(err)
            res(insert)
          })
        })
      })
    }
  },

  export: {
    description: '<path> <authorId> <parentId> exports template as value array for sql insert',

    exec(target) {
      return new Promise((res, rej) => {
        let p = Promise.resolve()

        fs.readdir('src/pages/', (err, files) => {
          files.forEach(file => {
            if (/^\./.test(file))
              return
            p = p.then(() => {
              return parseFile(`src/pages/${file}`, values)
            })
          })
          p.then(() => res(values.join(',\n  ')))
        })
      })
      .then(valueString => `insert into ${config.PSQL_SCHEMA}.page (author_id, route, title, template, data, parent_id) values\n  ${valueString}`)
      .then(insert => {
        return new Promise((res, rej) => {
          fs.writeFile('schema/2017-07-14T06:48:57.618Z-page-seed-data.sql', insert, (err) => {
            if (err)
              return rej(err)
            res(insert)
          })
        })
      })
    }
  }
}

function parseFile(path, values) {
  return new Promise((res, rej) => {
    fs.readFile(path, (err, data) => {
      if (err)
        rej(err)

      res(data)
    })
  })
  .then(str => {
    str = str.toString()

    let splitRe   = /<template>([\s\S]*)<\/template>[\s\S]*<script>([\s\S]*)<\/script>/gm
    let match     = splitRe.exec(str)
    let template  = match[1].replace(/\n/g, '')
    let script = {}

    try {
      script = eval(`(${match[2].replace(/^[^{]*/, '').trim()})`) || {}
    } catch (e) {
      console.error(e)
    }

    let data = script.data && script.data() || {}

    return values.push(`(${data.authorId || 1}, '${script.name}', '${data.title || null}', $$${template}$$, '${JSON.stringify(data)}', ${data.parentId || null})`)
  })
}
