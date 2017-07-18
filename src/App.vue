<template>
  <div id="app" class="container">
    <top-nav></top-nav>
    <transition name="fade" mode="out-in">
      <router-view class="view"></router-view>
    </transition>
    <div class="footer">
      powered by<img src="/public/skyClutch.gif" style="width:50px; margin: -7px;"/><a href="http://skyClutch.com" target="_blank">skyClutch, LLC</a>
    </div>
  </div>
</template>

<script>
export default {
  name: 'app'
}
</script>

<style lang="stylus">
@import './style/custom.styl'
html, body, .container
  height 100%

.footer
  font-size 12px
  color grey
  text-align center
  bottom 0px
  width 100%
  padding 5px
  opacity .9
  position fixed
  bottom 0
  left 0
  background white
  with 100%

  a
    color grey
  a:link
    text-decoration none
  a:hover
    color lightblue !important
    text-decoration none
  a:visited
    color grey
    text-decoration none
  a:active
    text-decoration none !important

hr
  background-color lightgrey

.backdrop
  top 0px
  width 100%
  background white
  opacity 0.7
  padding 25px

body
  color black
  font-family -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen, Ubuntu, Cantarell, "Fira Sans", "Droid Sans", "Helvetica Neue", sans-serif;
  font-size 18px
  margin 0
  padding-top 80px
  overflow-y scroll
  background: #dedede url("/public/background.jpg") no-repeat fixed center; 
  background-size cover

  a
    color black
  a:link
    color black
    text-decoration none
  a:hover
    color $light-blue
    text-decoration none
  a:visited
    text-decoration none
  a:active
    text-decoration none !important

.logo
  width 24px
  margin-right 10px
  display inline-block
  vertical-align middle

.view
  margin 0 auto
  position relative

.fade-enter-active, .fade-leave-active
  transition all .2s ease

.fade-enter, .fade-leave-active
  opacity 0

@media (max-width 860px)
  .header .inner
    padding 15px 30px

@media (max-width 600px)
  .header
    .inner
      padding 15px
    a
      margin-right 1em
    .github
      display none
</style>
