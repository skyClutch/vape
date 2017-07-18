<template>
  <header class="header">
		<b-navbar toggleable type="inverse" variant="info">

				<b-nav-toggle target="nav_collapse"></b-nav-toggle>

				<b-link class="navbar-brand" to="/">
					<span>District 14 PTA</span>
				</b-link>

				<b-collapse is-nav id="nav_collapse">

					<b-nav is-nav-bar>
            <router-link  v-for="page in topPages()" :key="page.id" :to="{ path: page.path, params: {} }">
                {{page.title}}
              </router-link>
					</b-nav>

				</b-collapse>
        <b-link href="https://twitter.com" target="_blank" right>
          <img src="/public/social-twitter.png" class="social-icon"/>
        </b-link>
		</b-navbar>
  </header>
</template>

<script>
  export default {
    name: 'top-nav',
    methods: {
      topPages() {
        return this.$store.state.pages.filter(p => !p.parentId)
      }
    }
  }
</script>

<style lang="stylus" scoped>
@import '../style/custom.styl'

li
  list-style none

.header
  background-color $theme-color
  position fixed
  z-index 9999
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
    line-height 30px
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
