const fwf     = require('fun_with_flags')
const fs      = require('fs')
const sedFile = require('../../util/sedFile')

module.exports = function (props) {
  // make sure config reloads
  delete require.cache[require.resolve('../../../../config/server')]
  const config = require('../../../../config/server')

  return fwf.shell('clear')
  .then(() => {
    console.log(`
Now we need to generate your initial db schema. We will register you as an admin user as well.
    `);
    
    return fwf.prompt([
      'ADMIN_FIRST_NAME', 
      'ADMIN_LAST_NAME', 
      'ADMIN_EMAIL', 
      'ADMIN_PASSWORD', 
    ])
  })
  .then(result => {
    Object.assign(props, result, config)
    return new Promise((resolve, reject) => {
      fs.readdir('./vape/default-schema/', (err, files) => {
        if (err)
          return reject(err)
        let result = 
        resolve({ files, props })
      })
    })
  })
  .then(({ files, props }) => {
    return Promise.all(files.map(file => {
      return sedFile(props, './vape/default-schema/'+file, './schema/'+file)
    }))
  })
}
