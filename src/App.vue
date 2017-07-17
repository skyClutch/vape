<template>
  <div id="app" class="container">
    <top-nav></top-nav>
    <transition name="fade" mode="out-in">
      <router-view class="view"></router-view>
    </transition>
    <div class="footer">
      <hr/>
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
.footer
  color lightgrey
  text-align center
  a
    color lightgrey
  a:link
    text-decoration none
  a:hover
    color lightblue !important
    text-decoration none
  a:visited
    color lightgrey
    text-decoration none
  a:active
    text-decoration none !important

$enable-rounded = true !default;
body
  font-family -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen, Ubuntu, Cantarell, "Fira Sans", "Droid Sans", "Helvetica Neue", sans-serif;
  font-size 15px
  margin 0
  padding-top 75px
  color #34495e
  overflow-y scroll

a
  color #34495e
  text-decoration none

.logo
  width 24px
  margin-right 10px
  display inline-block
  vertical-align middle

.view
  max-width 800px
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
