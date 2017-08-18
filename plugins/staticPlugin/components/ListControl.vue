<template>
  <div v-if="editing">
    <b-button @click="addItem" variant="success">+</b-button>
  </div>
</template>

<script>
import { getByPath } from '../../../vape/util'

  export default {
    computed: {
      editing() {
        return this.$store.state.editing
      }
    },

    methods: {
      addItem() {
        let list = getByPath(this.$store.state.page.data, this.list)
        list.push(Object.assign({}, this.blueprint))
        this.savePageData()
      }
    },

    name: 'list-control',

    props: ['blueprint', 'list']
  }
</script>
