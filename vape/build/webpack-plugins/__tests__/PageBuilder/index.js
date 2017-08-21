const pageBuilder = require('../../PageBuilder')

test('PageBuilder should work', done => {
  const compiler = {
    plugin: jest.fn((hook, callback) => {
      callback({}, () => { 
        expect(true).toBe(true)
        done()
      })
    })
  }

  const builder = new pageBuilder({})

  builder.apply(compiler)
})
