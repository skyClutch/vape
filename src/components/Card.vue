<template>
  <div class="col-4" v-on:click="logCard">
    <b-card 
      class="mb-2"
      v-bind:header="header"
      v-bind:img="img"
      v-bind:footer="footer"
      v-bind:overlay=true
      v-bind:title="title"
      v-bind:sub-title="subTitle"
    >
      {{ text }}
      <small v-if="footer" slot="footer" class="text-muted">
        {{ footer }}
      </small>
    </b-card>
  </div>
</template>

<script>
  export default {
    name: 'card',
    props: ['header', 'title', 'subTitle', 'footer', 'text', 'img', 'overlay'],
    methods: {
      logCard() {
        console.log(this.$options.propsData)
      }
    }
  }
</script>

<style lang="stylus" scoped>
  $lineHeight = 15
  $lineCount = 20

  div
    overflow hidden
    position relative
    line-height $lineHeight
    max-height $lineHeight * $lineCount 
    text-align justify
    margin-right -1em
    padding-right 1em

  div:before 
    content '...'
    position absolute
    right 0
    bottom 0

  div:after
    content ''
    position absolute
    right 0
    width 1em
    height 1em
    margin-top 0.2em
</style>
