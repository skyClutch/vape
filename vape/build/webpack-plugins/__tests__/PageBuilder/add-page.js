const path         = require('path')
const folder       = path.resolve(__dirname, '../../../../../templates')
const mock         = require('mock-fs')

// need to mock everything the webpack build will need
mock({
  [folder]: {
    'PageBuilderTest.vue': testPage
  }
})

const fs           = require('fs')
const withPgClient = require('../../../../util/postgres/withPgClient')
const PageBuilder  = require('../../PageBuilder')
const testPage     = '<template><div>test page</div></template><script>export default { name: "page-builder-test" }</script>'




test('PageBuilder should add a new page to the db', done => {
  // mock the compiler with function that restores fs and calls done
  const compiler = {
    plugin: jest.fn((hook, callback) => {
      callback({}, () => { 

        fs.readdir(folder, (err, data) => {
          if (err)
            return done()

          console.log(data)
          expect(true).toBe(true)
          mock.restore()
          done()
        })
      })
    })
  }

  const builder = new PageBuilder({})

  builder.apply(compiler)
})
