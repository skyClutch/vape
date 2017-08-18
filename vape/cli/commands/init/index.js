const writeConfig = require('./writeConfig')

module.exports = {
  description: 'init this vape project',

  exec(target) {
    return writeConfig(target)
  }
}
