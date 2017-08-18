const fwf = require('fun_with_flags')

module.exports = fwf.create({
  forms: require('./commands/forms'),
  init: require('./commands/init'),
  migrate: require('./commands/migrate'),
  template: require('./commands/template')
})
