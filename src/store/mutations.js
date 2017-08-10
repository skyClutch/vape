import Vue from 'vue'

export default {
  SET_ACTIVE_TYPE: (state, { type }) => {
    state.activeType = type
  },

  SET_LIST: (state, { type, ids }) => {
    state.lists[type] = ids
  },

  SET_ITEMS: (state, { items }) => {
    items.forEach(item => {
      if (item) {
        Vue.set(state.items, item.id, item)
      }
    })
  },

  SET_PAGE: (state, { page }) => {
    if (page)
      Vue.set(state.pages, page.id, page)
  },

  SET_PAGES: (state, { pages }) => {
    pages.forEach(page => {
      if (page) {
        Vue.set(state.pages, page.id, page)
      }
    })
  },

  SET_CURRENT_PAGE: (state, { page }) => {
    Vue.set(state, 'page', page)
  },

  SET_CURRENT_USER: (state, { user }) => {
    Vue.set(state, 'currentUser', user)
  },

  SET_USER: (state, { id, user }) => {
    Vue.set(state.users, id, user || false) /* false means user not found */
  }
}
