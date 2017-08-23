const fs = require('fs')

/**
 * does a find and replace on a src file with a set of props
 * writes to a target file
 * @param {object} props - a map of token/value pairs
 *   - tokens will be used to replace the pattern '%token%' with the value
 * @param {string} src - the src file path
 * @param {string} target - the target filename
 * @param {boolean} overwrite - overwrites file unless set to false
 */
module.exports = function (props, src, target, overwrite) {
  // read src
  return new Promise((resolve, reject) => {
    fs.readFile(src, (err, data) => {
      if (err)
        return reject(err)

      data = data.toString()


      for (let name in props) {
        let value = props[name]
        data = data.replace(new RegExp(`%${name}%`, 'gm'), value)
      }

      resolve(data)
    })
  })
  // remove existing target if overwrite is not strictly false
  .then(data => {
    return new Promise((resolve, reject) => {
      try {
        if (overwrite !== false) {
          fs.unlink(target, err => {
            resolve(data)
          })
        }
        else {
          resolve(data)
        }
      } 
      catch (err) {
        console.log(err)
        resolve(data)
      }
    })
  })
  // write target
  .then(data => {
    return new Promise((resolve, reject) => {
      fs.readFile(target, err => {
        // if we said no overwrite and there is no error (file is there) resolve without writing
        if (overwrite === false && !err) {
          console.log('skipping (file exists): ' + target)
          resolve()
        }
        // otherwise write file
        else {
          fs.writeFile(target, data, err => {
            if (err)
              reject(err)
            resolve()
          })
        }
      })
    })
  })
}
