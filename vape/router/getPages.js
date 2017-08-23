import apollo from '../ApolloClient'
import gql from 'graphql-tag'
import Vue from 'vue'
import templateFiles from '../../templates'

export default function (store) {
  // tet pages from the db
  return apollo().query({
    query: gql`{ allPages { edges { node {
            id
            name
            route
            template
            data
    } } } }` 
  })

  // get template for each page
  .then(result => {
    let pages = []

    try {
      pages = result.data.allPages.edges.map(edge => {
        let page = edge.node
        let data = {}

        try {
          data = JSON.parse(page.data)
        } catch (e) {
          console.error(e)
          data = {}
        }

        return Object.assign({}, page, { data })
      })
    } catch (e) {
      console.error(e)
    }

    return pages
  })
  
  // fixup data function and return route for router with page component
  .then(pages => {
    return pages.map(page => {
      let templateFile = Object.values(templateFiles).find(templateFile => templateFile.name === page.template)

      // fail if we no longer have a template file for this page
      if (!templateFile) {
        console.error(`Template file (${page.template}) no longer exists for page: ${page.name}`)
        return false
      }

      let pageData = templateFile.data || function () {}

      store.commit('SET_PAGE', { page })

      templateFile.data = function () {
        page.data = Object.assign({}, pageData.call(this), page.data)
        store.commit('SET_PAGE', { page })
        store.commit('SET_CURRENT_PAGE', { page })
        return page.data
      }

      return { 
        path      : page.route,
        component : templateFile
      }
    })
    .filter(page => { return !!page })
  })
}
