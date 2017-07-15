<template>
  <div>
    <card v-for="page in $store.state.page.data.children" :key="page.id"
      v-bind:path="page.data.route"
      v-bind:text="page.data.body"
      v-bind:img="page.data.img"
      v-bind:title="page.data.title"
      v-bind:sub-title="page.data.subTitle"
    ></card>
  </div>
</template>

<script>
  export default {
    name: 'programs',
    data: () => ({
      title: 'Programs',
      body: 'here have some text'
    })
  }
</script>
