<template>
  <div>
    <b-jumbotron :header="title" :style="{ color: 'white', background: '#000 url(' + img + ') center center' }">
    </b-jumbotron>
  </div>
</template>

<script>
  export default {
    name: 'jumbo-tron',
    props: ['img', 'title']
  }
</script>

<style lang="stylus" scoped>
  b-jumbotron
    position relative
    background 
    width 100%
    height 100% 
    background-size cover
    overflow hidden
</style>
