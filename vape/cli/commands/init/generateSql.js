const fwf     = require('fun_with_flags')
const fs      = require('fs')
const sedFile = require('../../util/sedFile')
const crypto  = require('crypto')
const path = require('path')

module.exports = function (props) {
  // make sure config reloads
  delete require.cache[path.resolve('./config/server')]
  const config = require(path.resolve('./config/server'))
  const adminDefaultPassword = crypto.randomBytes(20).toString('hex')

  console.log(`
Now we need to generate your initial db schema. We will register you as an admin user as well.
    `);
    
  return fwf.prompt([
    {
      name: 'ADMIN_FIRST_NAME', 
      message: 'Please enter your first name'
    },
    {
      name: 'ADMIN_LAST_NAME', 
      message: 'Please enter your last name'
    },
    {
      name: 'ADMIN_EMAIL', 
      message: 'Please enter your email',
      default: props.INSECURE_GMAIL_USERNAME
    },
    {
      name: 'ADMIN_PASSWORD', 
      message: 'Enter a password for logging into your application if you wish, or hit enter to have a secure password generated for you',
      default: adminDefaultPassword,
      hidden: true
    }
  ])

  // get default schema files
  .then(result => {
    Object.assign(props, result, config)

    // log out generated password if used
    if (props.ADMIN_PASSWORD === adminDefaultPassword)
      console.log('Your application password is: ', props.ADMIN_PASSWORD)

    return new Promise((resolve, reject) => {
      fs.readdir('./vape/default-schema/', (err, files) => {
        if (err)
          return reject(err)
        let result = 
        resolve({ files, props })
      })
    })
  })

  // copy and replace keys
  .then(({ files, props }) => {
    return Promise.all(files.map(file => {
      return sedFile(props, './vape/default-schema/'+file, './schema/'+file)
    }))
  })
}
