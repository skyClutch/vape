const ModuleBuilder = require('../../ModuleBuilder')
const mock          = require('mock-fs')
const fs            = require('fs')

mock({
  components: {
    'Nav.vue'    : '<template><nav></nav></template>',
    'Footer.vue' : '<template><foot></foot></template>',
    subfolder: {
      'foo.vue': '<template>bar</template>'
    }
  }
})

test('Builder should include subfolders', done => {
  // mock the compiler with function that restores fs and calls done
  const compiler = {
    plugin: jest.fn((hook, callback) => {
      callback({}, () => { 
        fs.readFile('components/index.js', (err, data) => {
          if (err)
            return done()

          expect(/subfolder/m.test(data.toString())).toBe(true)
          mock.restore()
          done()
        })
      })
    })
  }

  const builder = new ModuleBuilder({ folders: ['components']  })

  builder.apply(compiler)
})

test('Subfolder should also get new index file', done => {
  // mock the compiler with function that restores fs and calls done
  fs.readdir('components/subfolder', (err, data) => {
    if (err)
      return done()

    expect(data.indexOf('index.js') > -1).toBe(true)
    mock.restore()
    done()
  })
})
