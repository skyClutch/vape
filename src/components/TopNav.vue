<template>
  <header class="header">
    <nav class="inner">
      <router-link to="/home">home</router-link>
      <router-link to="/welcome">welcome</router-link>
      <router-link to="/calendar">calendar</router-link>
      <router-link to="/programs">programs</router-link>
      <router-link to="/forms">forms</router-link>
      <router-link to="/resources">resources</router-link>
      <a class="github" href="https://github.com/vuejs/vue-hackernews-2.0" target="_blank" rel="noopener">
        Built with Vue.js
      </a>
    </nav>
  </header>
</template>

<script>
</script>

<style lang="stylus" scoped>
@import '../style/vars.styl'

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
