import Vue from 'vue'
import 'es6-promise/auto'
import { createApp } from './app'
import ProgressBar from './components/ProgressBar.vue'

// global progress bar
const bar = Vue.prototype.$bar = new Vue(ProgressBar).$mount()
document.body.appendChild(bar.$el)

// a global mixin that calls `asyncData` when a route component's params change
// Vue.mixin({
  // beforeRouteUpdate (to, from, next) {
  //   const { asyncData } = this.$options
  //   const ComponentData = this.$options.data || (() => ({}))
  //   if (asyncData) {
  //     asyncData({
  //       store: this.$store,
  //       route: to
  //     })
  //     .then(asyncResult => {
  //       this.$options.data = function () {
  //         const data =  ComponentData.apply(this, arguments)
  //         return Object.assign(data, asyncResult)
  //       }
  //       return null
  //     })
  //     .then(next)
  //     .catch(next)
  //   } else {
  //     next()
  //   }
  // }
// })

createApp()
.then(({ app, router, store }) => {
  // prime the store with server-initialized state.
  // the state is determined during SSR and inlined in the page markup.
  if (window.__INITIAL_STATE__) {
    store.replaceState(window.__INITIAL_STATE__)
  }

  // wait until router has resolved all async before hooks
  // and async components...
  router.onReady(() => {
    // Add router hook for handling asyncData.
    // Doing it after initial route is resolved so that we don't double-fetch
    // the data that we already have. Using router.beforeResolve() so that all
    // async components are resolved.
    router.beforeResolve((to, from, next) => {
      const matched = router.getMatchedComponents(to)
      const prevMatched = router.getMatchedComponents(from)
      let diffed = false
      // const activated = matched.filter((c, i) => {
      //   return diffed || (diffed = (prevMatched[i] !== c))
      // })
      const asyncDataHookComponents = matched.filter(c => !!c.asyncData)
      if (!asyncDataHookComponents.length) {
        return next()
      }

      bar.start()
      Promise.all(asyncDataHookComponents.map(Component => {
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
      .then(() => {
        bar.finish()
        next()
      })
      .catch(next)
      .finally(() => {
        // actually mount to DOM
        app.$mount('#app')
      })
    })
  })

  // service worker
  if ('https:' === location.protocol && navigator.serviceWorker) {
    navigator.serviceWorker.register('/service-worker.js')
  }
})
