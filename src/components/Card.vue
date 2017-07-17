<template>
  <div class="col-md-4">
    <router-link :to="path">
      <b-card 
        class="mb-2"
        :header="header"
        :img="img"
        :footer="footer"
        :overlay=true
        :title="title"
        :sub-title="subTitle"
      >
        {{ snippet(text) }}
        <small v-if="footer" slot="footer" class="text-muted">
          {{ footer }}
        </small>
      </b-card>
    </router-link>
  </div>
</template>

<script>
  export default {
    name: 'card',

    props: ['path', 'header', 'title', 'subTitle', 'footer', 'text', 'img', 'overlay'],

    methods: {
      snippet: body => `${body.slice(0, 100)}...`.replace(/<[^>\/]\/*>/g, '')
    }
  }
</script>
