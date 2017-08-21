const sedFile = require('../../sedFile')
const mock    = require('mock-fs')
const fs      = require('fs')

mock({
  test: {
    'schema-template.sql': 'create schema %SCHEMA%;',
    'schema.sql': 'create schema prod_schema;'
  }
})

test('sedFile should overwrite an existing target file', done => {
  return sedFile({ SCHEMA: 'test_schema' }, 'test/schema-template.sql', 'test/schema.sql')
  .then(() => {
    fs.readFile('test/schema.sql', (err, data) => {
      if (err)
        console.error(err)
      expect(data.toString()).toEqual('create schema test_schema;')
      mock.restore()
      done()
    })
  })
  .catch(err => console.error(err))
})
