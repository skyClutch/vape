<template>
  <div class="col-md-4">
    <router-link :to="path">
      <b-card 
        class="mb-2"
        :header="header"
        :footer="footer"
        :title="title"
        :sub-title="subTitle"
        :style="{ background: (idx % 2 === 0 ? '#fff' : '#eee'), color: 'black' }"
      >
        {{ snippet(text) }}
      </b-card>
    </router-link>
  </div>
</template>

<script>
  export default {
    name: 'card',

    props: ['idx', 'path', 'header', 'title', 'subTitle', 'footer', 'text', 'img'],

    methods: {
      snippet: body => body.replace(/<[^>]+>/g, '').slice(0, 200) + '...'
    }
  }
</script>
