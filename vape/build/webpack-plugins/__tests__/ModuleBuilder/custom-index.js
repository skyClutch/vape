const ModuleBuilder = require('../../ModuleBuilder')
const mock          = require('mock-fs')
const fs            = require('fs')
const customIndex   = '/* custom index not built by ModuleBuilder */'

mock({
  components: {
    'Nav.vue'    : '<template><nav></nav></template>',
    'Footer.vue' : '<template><foot></foot></template>',
    'index.js'   : customIndex
  }
})

test('ModuleBuilder should not overwrite custom index file', done => {
  // mock the compiler with function that restores fs and calls done
  const compiler = {
    plugin: jest.fn((hook, callback) => {
      callback({}, () => { 
        fs.readFile('components/index.js', (err, data) => {
          if (err)
            return done()

          expect(data.toString()).toEqual(customIndex)
          mock.restore()
          done()
        })
      })
    })
  }

  const builder = new ModuleBuilder({ folders: ['components']  })

  builder.apply(compiler)
})
