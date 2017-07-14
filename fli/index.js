const fwf = require('fun_with_flags')

module.exports = fwf.create({
  migrate: require('./commands/migrate'),
  template: require('./commands/template')
})
