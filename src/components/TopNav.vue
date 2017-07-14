<template>
  <header class="header">
    <nav class="inner">
      <span v-for="page in $store.state.pages" :key="page.id">
        <router-link :to="{ path: page.path, params: {} }">{{page.title}}</router-link>
      </span>
    </nav>
  </header>
</template>

<script>
  export default {
    name: 'top-nav'
  }
</script>

<style lang="stylus" scoped>
@import '../style/vars.styl'

li
  list-style none

.header
  background-color $theme-color
  position fixed
  z-index 999
  height 55px
  top 0
  left 0
  right 0
  .inner
    max-width 800px
    box-sizing border-box
    margin 0px auto
    padding 15px 5px
  a
    color rgba(255, 255, 255, .8)
    line-height 24px
    transition color .15s ease
    display inline-block
    vertical-align middle
    font-weight 300
    letter-spacing .075em
    margin-right 1.8em
    &:hover
      color #fff
    &.router-link-active
      color #fff
      font-weight 400
    &:nth-child(7)
      margin-right 0
  .github
    color #fff
    font-size .9em
    margin 0
    float right
</style>
