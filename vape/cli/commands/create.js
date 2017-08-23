const fs   = require('fs')
const fwf  = require('fun_with_flags')
const path = require('path')

module.exports = {
  description: '<dirPath> creates a vape project at the given dirPath',

  exec(target, dirPath = '') {
    const parentDir = (dirPath.split('/').slice(0, -1).join('/') || '.') + '/'
    const dir       = dirPath.split('/').slice(-1)[0]

    if (!dirPath)
      return Promise.reject('Please provide a dirPath for your project.')

    dirPath = path.resolve(dirPath)

    return new Promise((resolve, reject) => {
      // check the dirPath
      fs.readdir(parentDir, (err, data) => {
        if (err)
          return reject('Invalid Path')

        // warn user of impending action
        console.log(`Getting ready to init Vape project in ${dirPath}`)

        // prompt if folder already exists
        if (data.indexOf(dir) > -1)
          return resolve(fwf.prompt([{
            name: 'writeInto',
            message: 'Directory exists. Init as a Vape project(y/n)? (some files may be overwritten)'
          }]))

        // otherwise assume yes
        return resolve({ writeInto: 'y' })
      })
    })

    // exit if they said no
    .then(props => {
      if (props.writeInto !== 'y')
        return process.exit()

      // copy project files
      return fwf.shell(`
vape=$(pwd)/vape
mkdir ${dirPath}
cp -r ./. ${dirPath}
cd ${dirPath}
rm -rf .git
rm *-fwf-cmd.sh
rm -rf vape
ln -s "$vape" "$(pwd)/vape"
      `)
    })
    .then(result => `Vape project created in ${dirPath}`)
  }
}
