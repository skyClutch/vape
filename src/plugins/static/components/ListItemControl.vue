<template>
  <div style="position: relative; width: 100%; z-index: 99999;">
    <div style="position: absolute; right: 0px;">
      <b-button 
        @click="moveLeft"
        size="sm" variant="primary" 
        >&lt;&lt;</b-button> 
      <b-button 
        @click="deleteItem"
        size="sm" variant="danger" 
        >x</b-button> 
      <b-button 
        @click="moveRight"
        size="sm" variant="primary" 
        >&gt;&gt;</b-button>
    </div>
  </div>
</template>

<script>
  export default {
    inject: ['list', 'item'],

    methods: {
      deleteItem() {
        this.list.splice(this.list.indexOf(this.item), 1)
        this.destroyAndSave()
      },

      destroyAndSave() {
        this.$el.remove()
        this.$destroy()
        this.savePageData()
      },

      moveLeft() {
        let idx = this.list.indexOf(this.item)

        // bail if we can't move left
        if (idx === 0)
          return

        this.list.splice(idx, 1)
        this.list.splice(idx - 1, 0, this.item)
      },

      moveRight() {
        let idx = this.list.indexOf(this.item)

        // bail if we can't move right
        if (idx === this.list.length - 1)
          return

        this.list.splice(idx, 1)
        this.list.splice(idx + 1, 0, this.item)
      }
    }
  }
</script>
