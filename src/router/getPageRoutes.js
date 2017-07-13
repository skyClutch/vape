import apollo from '../lib/apollo-client'
import gql from 'graphql-tag'
import Vue from 'vue'


export default function getPageRoutes() {
  return apollo.query({
    query: gql`{
      allPages {
        edges {
          node {
            id
            parentId
            route
            title
            template
            data
          }
        }
      }
    }`
  })
  .then(result => {
    try {
      return result.data.allPages.edges.map(edge => {
        let page = edge.node
        let data = {}

        try {
          data = JSON.parse(page.data)
        } catch (e) {
          console.error(e)
          data = {}
        }

        data.title = page.title

        return { 
          path: `/${page.route}`, 
          component: Vue.component(page.route, {
            data: () => data,
            template: page.template
          })
        }
      })
    } catch (e) {
      console.error(e)
      return []
    }
  })
}
