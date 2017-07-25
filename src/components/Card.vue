<template>
  <div class="col-md-4">
    <router-link v-if="!!path" :to="path">
        <b-card 
          class="mb-2"
          :header="header"
          :footer="footer"
          :title="title"
          :sub-title="subTitle"
          :style="{ background: (idx % 2 === 0 ? '#fff' : '#eee'), color: 'black' }"
        >
        <div class="snippet">{{ snippet(text) }}</div>
        </b-card>
    </router-link>
    <a v-if="!!url" :href="url" target="_blank">
        <b-card 
          class="mb-2"
          :header="header"
          :footer="footer"
          :title="title"
          :sub-title="subTitle"
          :style="{ background: (idx % 2 === 0 ? '#fff' : '#eee'), color: 'black' }"
        >
          <span class="snippet">{{ text }}</span>
        </b-card>
    </a>
  </div>
</template>

<script>
  export default {
    name: 'card',

    props: ['url', 'idx', 'path', 'header', 'title', 'subTitle', 'footer', 'text', 'img'],

    methods: {
      snippet: body => body && body.replace(/<[^>]+>/g, '').slice(0, 150) + '...'
    }
  }
</script>

<style lang="scss">
.card {
  border: none;
  border-radius: 0;
  opacity: 0.6;
  color: white;
  height: 100%;
  min-height: 200px;
  cursor: pointer;
}

.card:hover {
  background: #666 !important;
  color: white !important;
  opacity: 0.7;
}
</style>
