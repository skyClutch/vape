const writeConfig = require('./writeConfig')
const generateSql = require('./generateSql')
const fwf         = require('fun_with_flags')

module.exports = {
  description: 'init this vape project',

  exec(target) {
    return writeConfig(target)
    .then(props => {
      return generateSql(props)
    })
    .then(() => {
      return `
Your config and default sql have been generated. Please run \`npm run vape migrate run\` to setup your db.
If you need to overwrite a previous setup, run \`npm run vape migrate run -- --drop\`
Once that runs, run \`npm run dev\` to startup your app.
    `})
  }
}
