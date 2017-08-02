<template>
  <div>
    <b-button @click="addItem" variant="success">+</b-button>
  </div>
</template>

<script>
import { getByPath } from '../../../util'

  export default {
    methods: {
      addItem() {
        let list = getByPath(this.$store.state.page.data, this.list)
        list.unshift(Object.assign({}, this.blueprint))
        window.list = list
        this.savePageData()
      }
    },

    name: 'list-control',

    props: ['blueprint', 'list']
  }
</script>
