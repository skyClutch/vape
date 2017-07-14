<template>
  <div>
    <card v-for="page in $store.state.page.data.children" :key="page.id"
      v-bind:text="snippet(page.data.body)"
      v-bind:img="page.data.img"
      v-bind:title="page.data.title"
      v-bind:sub-title="page.data.subTitle"
    ></card>
  </div>
</template>

<script>
  export default {
    name: 'home',
    data: () => ({
      title: 'Home'
    }),
    methods: {
      snippet: text => `${text.slice(0,10)}...`
    }
  }
</script>
