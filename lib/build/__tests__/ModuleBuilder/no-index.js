const ModuleBuilder = require('../../ModuleBuilder')
const mock          = require('mock-fs')
const fs            = require('fs')

mock({
  components: {
    'Nav.vue'    : '<template><nav></nav></template>',
    'Footer.vue' : '<template><foot></foot></template>'
  }
})

test('Builder should add index file to folder without one', done => {
  // mock the compiler with function that restores fs and calls done
  const compiler = {
    plugin: jest.fn((hook, callback) => {
      callback({}, () => { 
        fs.readdir('components', (err, data) => {
          if (err)
            return done()

          expect(data.indexOf('index.js') > -1).toBe(true)
          mock.restore()
          done()
        })
      })
    })
  }

  const builder = new ModuleBuilder({ folders: ['components']  })

  builder.apply(compiler)
})
