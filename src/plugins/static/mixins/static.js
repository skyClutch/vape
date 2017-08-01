import setByPath from '../../../util/setByPath'
import deleteByPath from '../../../util/deleteByPath'
import apollo from '../../../lib/ApolloClient'
import gql from 'graphql-tag'

export default {
  methods: {
    deleteStatic() {
      let page = this.$store.state.page
      
      deleteByPath(page.data, this.path)
      savePageData(page)
      this.$el.remove()
      this.$destroy()
    },

    setStatic(path, value, context = this) {
      let page = this.$store.state.page

      setByPath(context, path, value)
      savePageData(page)
    }
  }
}

function savePageData(page) {
  let json = JSON.stringify(page.data)
  
  return apollo().mutate({
    mutation: gql`mutation ($id: Int!, $data: Json) {
      updatePageById(input: {id: $id, pagePatch: {
        data: $data
      }
      }){page {id, data}}
    }`,
    variables: {
      id: page.id,
      data: json
    }
  })
}
