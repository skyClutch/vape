# 1  Vape
Vape is awesome

## 1.1  TODO

### 1.1.1  cms

- add control for removing all formatting to v-static
  - leave semantic html
  - this is half-done (see util in the static plugin folder)
- add layouts
- add the rest of the pages
  - make pages, components, layouts, plugins all build automatically from files in folders
- add markdown support
- add file upload
- add auto-image upload
- add settings page

### 1.1.2  pta site

- add twitter
- add google calendar
- add contact form

### 1.1.3  frontend

- fix double load of asyncData
  - prob in entry file

### 1.1.4  backend

- finish auth
  - add auth endpoint
    - set cookie with token
    - add middleware to copy token from cookie to auth header
  - add login/signup page
    - add verification/reset workflow
    - add verification step for admin
- extend api
- add acl
  - must provide utility for extensions to use auth/acl


### 1.1.5  possible ssr solution
```
if (!process.BROWSER_BUILD) {
  const jsdom = require('jsdom')
    const { JSDOM } = jsdom
    const dom = new JSDOM(``)
    global.window = dom.window
    global.document = dom.window.document
    global.Element = dom.window.Element
}

var Vue = require('vue')
var VueMaterial = require('vue-material')
Vue.use(VueMaterial)
```
