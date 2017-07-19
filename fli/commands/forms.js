const fs = require('fs')

module.exports = {
  export: {
    description: 'exports a list of files in json from the /public/forms/ folder',

    display(result) {
      let objList = result.map(file => {
        let split = file.split('.')
        return {
          type: split.slice(-1)[0],
          title: split.slice(0, -1).join(' ').replace(/[-_]|\s+/g, ' '),
          path: `/public/forms/${file}`,
          text: 'replace me'
        }
      })

      return JSON.stringify(objList,null,2)
    },

    exec(target) {
      return new Promise((res, rej) => {
        fs.readdir('./public/forms', (err, files) => {
          if (err)
            rej(err)
          else
            res(files)
        })
      })
    }
  }
}
