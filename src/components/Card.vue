<template>
  <div class="col-4" v-on:click="logCard">
    <b-card 
      class="mb-2"
      v-bind:header="header"
      v-bind:img="img"
      v-bind:footer="footer"
      v-bind:overlay="overlay"
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
  div
    text-overflow ellipsis
</style>
