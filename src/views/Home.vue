<template>
  <div>
    home
    {{pages}}
  </div>
</template>

<script>
  import apollo from '../lib/apollo-client'
  import gql from 'graphql-tag'

  export default {
    name: 'home',

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
        const mapped  = { pages: result.data.allPages.edges.map(edge => edge.node) }
        return mapped
      })
    }
  }
</script>
