<template>
<div>home<hr />
<card v-for="page in $store.state.page.children" :key="page.id"
  v-bind:text="page.data.body"
  v-bind:img="page.data.img"
  v-bind:title="page.data.title"
  v-bind:sub-title="page.data.subTitle"
></card>
</div>
</template>

<script>
  export default {
    name: 'home',
  }
</script>
