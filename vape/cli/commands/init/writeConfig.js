const fwf     = require('fun_with_flags')
const fs      = require('fs')
const sedFile = require('../../util/sedFile')

module.exports = function (target) {
  const props = {}

  // prompt for config values
  return fwf.shell('clear')
  .then(() => {
    console.log(`
Initting vape project. Well ask some questions to setup your project config. 
You can change these via the config folder any time,
so if you don't know the answer or don't intend on using a feature, just leave it blank and hit enter.
Warning: This will overwrite an existing config. Press CTRL-C to abort.
    `)

    return fwf.prompt([{
      name: 'APP_TITLE',
      message: 'What is the title of your project?'
    }])
  })
  .then(result => {
    Object.assign(props, result)

    console.log(`
Vape has a simple gmail integration that uses gmail's insecure apps feature. 
If you'd rather use a different solution, feel free to skip this.
If you do use it, make sure to turn on insecure apps in your gmail settings.
    `)

    return fwf.prompt([{
      name: 'INSECURE_GMAIL_USERNAME',
      message: 'Please enter your gmail username'
    }
    , {
      name: 'INSECURE_GMAIL_PASSWORD',
      message: 'Please enter your gmail password'
    }
    ])
  })
  .then(result => {
    Object.assign(props, result)

    console.log(`
Everything in vape is driven by your db schema - Authentication, Athentication, Authorization, Access Control, API Structure and behavior, and more. 
You need a good name for your schema, as well as good usernames and passwords for your application, as well as db admin functions.
    `)

    return fwf.prompt([{
      name: 'DB_NAME',
      message: 'Please enter the name of your db'
    },
    {
      name: 'HOST',
      default: 'localhost',
      message: 'Please enter the hostname for your db (defaults to localhost)'
    },
    {
      name: 'PORT',
      default: '5432',
      message: 'Please enter the port for your db (defaults to 5432)'
    },
    {
      name: 'SCHEMA',
      message: 'Please enter a good name for your db schema'
    },
    {
      name: 'APP_PASSWORD',
      message: 'Please enter a password for your application to use when accessing the db'
    },
    {
      name: 'ADMIN_USERNAME',
      message: 'Please enter the username for an superuser on your db'
    },
    {
      name: 'ADMIN_PASSWORD',
      message: 'Please enter the password for the superuser'
    },
    {
      name: 'SECRET',
      message: 'Please enter a random string to be used as an encryption key for your app'
    }])
  })
  // extend props with last result
  .then(result => {
    Object.assign(props, result)
    return props
  })
  // replace values from default config
  .then(props => {
    return sedFile(props, './vape/default-config/server.js', './config/server.js')
  })
  .then(() => {
    console.log('Your config has been written (see config/server.js)')
    return props;
  })
}
