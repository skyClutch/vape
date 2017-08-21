const sedFile = require('../../sedFile')
const mock    = require('mock-fs')
const fs      = require('fs')

mock({
  test: {
    'schema-template.sql': 'create schema %SCHEMA%;',
    'schema.sql': 'create schema prod_schema;'
  }
})

test('sedFile should not overwrite existing target when overwrite flag is false', done => {
  return sedFile({ SCHEMA: 'test_schema' }, 'test/schema-template.sql', 'test/schema.sql', false)
  .then(() => {
    fs.readFile('test/schema.sql', (err, data) => {
      if (err)
        console.error(err)
      expect(data.toString()).not.toEqual('create schema test_schema;')
      mock.restore()
      done()
    })
  })
})
