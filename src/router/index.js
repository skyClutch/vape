import Vue from 'vue'
import Router from 'vue-router'
import getPages from './getPages'

Vue.use(Router)

export function createRouter (store) {
  return getPages(store)
  .then(pageRoutes => {
    return new Router({
      mode: 'history',
      scrollBehavior: () => ({ y: 0 }),
      routes: [
        { path: '/', redirect: '/home' }
      ].concat(pageRoutes)
    })
  })
}
