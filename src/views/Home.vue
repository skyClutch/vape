<template>
  <div>
    home
    {{$store.state.pages}}
  </div>
</template>

<script>
  import apollo from '../lib/apollo-client'
  import gql from 'graphql-tag'

  export default {
    name: 'top-nav',

    asyncData: ({ store, route }) => {
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
        store.commit('SET_PAGES', { 
          pages: result.data.allPages.edges.map(edge => {
            return edge.node
          })
        })
      })
    }
  }
</script>
