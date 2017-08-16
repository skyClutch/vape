import setByPath from '../../../lib/util/setByPath'
import deleteByPath from '../../../lib/util/deleteByPath'
import apollo from '../../../lib/ApolloClient'
import gql from 'graphql-tag'

export default {
  methods: {
    setStatic(path, value, context = this) {
      setByPath(context, path, value)
      this.savePageData()
    },

    savePageData() {
      let page = this.$store.state.page
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
  }
}

