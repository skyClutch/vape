const sedFile = require('../../sedFile')
const mock    = require('mock-fs')
const fs      = require('fs')

mock({
  test: {
    'schema-template.sql': 'create schema %SCHEMA%;'
  }
})

test('sedFile should write a target file with tokens replaced with values', done => {
  return sedFile({ SCHEMA: 'test_schema' }, 'test/schema-template.sql', 'test/schema-template.sql')
  .then(() => {
    fs.readFile('test/schema-template.sql', (err, data) => {
      if (err)
        console.error(err)
      expect(data.toString()).toEqual('create schema test_schema;')
      mock.restore()
      done()
    })
  })
  .catch(err => console.error(err))
})
