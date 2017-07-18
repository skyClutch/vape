<template>
  <div class="page-title-wrapper">
    <div class="page-title">
      <div class="container">
        <h1>{{title}}</h1>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    name: 'jumbo-tron',
    props: ['img', 'title']
  }
</script>

<style lang="stylus" scoped>
  .page-title-wrapper
    height 100px
    width 100%

  .page-title
    color white
    position fixed
    padding 30px
    top 55px
    left 0px
    width 100%
    height 100px
    background rgba(157,171,205,0.9)
    z-index 999
</style>
