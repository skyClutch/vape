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
      return null
    })
    .then(() => {
      console.log('Adding https://github.com/skyclutch/vape.git as upstream so you can stay up to date and contribute to the vape project more easily.') 
      return fwf.shell(`
git remote add upstream https://github.com/skyclutch/vape.git
git fetch upstream
      `)
    })
    .then(() => {
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
    .then(result => `
Vape project created in ${dirPath}. 
To init your project, run:

$ cd ${dirPath} && npm install && npm run vape init

You may need to run with sudo depending on your system\'s permisions
If anyting goes wrong, you can just delete the folder created and try again with sudo.
    `)
    .catch(err => {
      console.log('Something has gone wrong:')
      console.error(err)
    })
  }
}
