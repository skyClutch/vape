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
  beforeMount (to, from, next) {
    const { asyncData } = this.$options
    const ComponentData = this.$options.data || (() => ({}))

    if (asyncData) {
      asyncData({
        store: this.$store,
        route: to
      })
      .then(asyncResult => {
        this.$options.data = function () {
          const data =  ComponentData.apply(this, arguments)
          return Object.assign(data, asyncResult)
        }
        return null
      })
    }
  }
})

Vue.use(staticPlugin)

createApp()
.then(({ app, router, store }) => {
  // prime the store with server-initialized state.
  // the state is determined during SSR and inlined in the page markup.
  if (window.__INITIAL_STATE__) {
    store.replaceState(window.__INITIAL_STATE__)
  }

  // set initial page
  Vue.set(store.state, 'page', Object.values(store.state.pages).find(page => page.id === store.state.page.id))

  // wait until router has resolved all async before hooks
  // and async components...
  router.onReady(() => {
    // Add router hook for handling asyncData.
    // Doing it after initial route is resolved so that we don't double-fetch
    // the data that we already have. Using router.beforeResolve() so that all
    // async components are resolved.
    router.beforeResolve((to, from, next) => {
      bar.start()
      resolveComponents(store, router, to, from)
      .then(() => {
        bar.finish()
        next()
      })
      .catch(next)
    })
  })

  resolveComponents(store, router)
  .then(() => {
    app.$mount('#app')
  })

  // service worker
  if ('https:' === location.protocol && navigator.serviceWorker) {
    navigator.serviceWorker.register('/service-worker.js')
  }
})

function resolveComponents(store, router, to, from) {
  const matched = router.getMatchedComponents(to)

  let activated = matched
  let diffed = false

  if (to && from) {
    const prevMatched = router.getMatchedComponents(from)
    const activated = matched.filter((c, i) => {
      return diffed || (diffed = (prevMatched[i] !== c))
    })
  }

  const asyncDataHookComponents = activated.filter(c => !!c.asyncData)
  if (!asyncDataHookComponents.length) {
    return Promise.resolve(null)
  }

  return Promise.all(asyncDataHookComponents.map(Component => {
    const ComponentData = Component.data || (() => ({}))
    const asyncData = Component.asyncData

    return asyncData({ store, route: to })
    .then(asyncResult => {
      Component.data = function () {
        const data =  ComponentData.call(this)
        return Object.assign(data, asyncResult)
      }
      if (Component._Ctor && Component._Ctor[0] && Component._Ctor[0].options) {
        Component._Ctor[0].options.data = Component.data
      }
      return null
    })
  }))
}
