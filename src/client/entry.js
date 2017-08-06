import Vue from 'vue'
import 'es6-promise/auto'
import { createApp } from '../app'
import ProgressBar from '../components/ProgressBar.vue'
import { staticPlugin } from '../plugins'

// global progress bar
const bar = Vue.prototype.$bar = new Vue(ProgressBar).$mount()
document.body.appendChild(bar.$el)

// a global mixin that calls `asyncData` when a route component's params change
Vue.mixin({
  beforeMount () {
    const { asyncData } = this.$options
    const ComponentData = this.$options.data || (() => ({}))

    if (asyncData) {
      asyncData.call(this)
      .then(asyncResult => {
        for (let i in asyncResult) {
          this[i] = asyncResult[i]
        }
        this.$options.data = function () {
          const data =  ComponentData.apply(this, arguments)
          return Object.assign(data, asyncResult)
        }
        // add data to to cache
        if (this._Ctor && this._Ctor[0] && this._Ctor[0].options) {
          this._Ctor[0].options.data = this.data
        }
        return null
      })
    }
  }
})

// add static plugin
Vue.use(staticPlugin)

createApp()
.then(({ app, router, store }) => {
  // prime the store with server-initialized state.
  // the state is determined during SSR and inlined in the page markup.
  if (window.__INITIAL_STATE__) {
    store.replaceState(window.__INITIAL_STATE__)
    router.history.updateRoute(router.resolve(store.state.route.fullPath).resolved)
  }

  // set initial page
  Vue.set(store.state, 'page', Object.values(store.state.pages).find(page => page.id === store.state.page.id))

  // wait until router has resolved all async before hooks
  // and async components...
  router.onReady(() => {
      app.$mount('#app')
  })

  // service worker
  if ('https:' === location.protocol && navigator.serviceWorker) {
    navigator.serviceWorker.register('/service-worker.js')
  }
})
