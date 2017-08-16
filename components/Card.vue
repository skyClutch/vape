<template>
  <div style="overflow-x: hidden;" :class="`col-md-${size}`" v-if="!!path" >
    <router-link :to="path">
        <b-card 
          class="mb-2"
          :header="header"
          :footer="footer"
          :title="title"
          :sub-title="subTitle"
          :style="{ background: (idx % 2 === 0 ? '#fff' : '#eee'), color: 'black' }"
        >
        <div class="snippet" v-html="text"></div>
        </b-card>
    </router-link>
  </div>
  <div  style="overflow-x: hidden;" :class="`col-md-${size}`" v-else-if="!!url">
    <a :href="url" target="_blank">
        <b-card 
          class="mb-2"
          :header="header"
          :footer="footer"
          :title="title"
          :sub-title="subTitle"
          :style="{ background: (idx % 2 === 0 ? '#fff' : '#eee'), color: 'black' }"
        >
          <div class="snippet" v-html="text"></div>
        </b-card>
    </a>
  </div>
  <div  style="overflow-x: hidden;" :class="`col-md-${size} no-link`" v-else-if="!url && !path">
      <b-card 
        class="mb-2"
        :header="header"
        :footer="footer"
        :title="title"
        :sub-title="subTitle"
        :style="{ background: (idx % 2 === 0 ? '#fff' : '#eee'), color: 'black' }"
      >
        <div class="snippet" v-html="text"></div>
      </b-card>
  </div>
</template>

<script>
  export default {
    name: 'card',

    props: {
      idx      : { default: 0, type: Number },
      path     : String,
      header   : String,
      footer   : String,
      img      : String,
      size     : { default: "4" },
      subTitle : String,
      text     : String,
      title    : String,
      url      : String
    },

    methods: {
      snippet: body => body && body.replace(/<[^>]+>/g, '').slice(0, 150) + '...'
    }
  }
</script>

<style lang="stylus" scoped>
  .card
    border none
    border-radius 0
    opacity 0.7
    color white
    height 100%
    min-height 200px
    margin-bottom 0px !important

  .card:hover
    background #666 !important
    color white !important
    opacity 0.8

  .col-md-8
    padding 0px

  .no-link
    .card:hover
      background #eee !important
      color: black !important
      opacity: 0.8
</style>
