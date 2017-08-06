<template>
  <div class="row">
    <jumbo-tron :title="title"></jumbo-tron>
    <card v-for="(page, idx) in $store.state.page.data.children" :key="page.id"
      :text="page.data.body"
      :img="page.data.img"
      :title="page.data.title"
      :sub-title="page.data.subTitle"
      :idx="idx"
      v-static="{ '.card-title': 'title', '.snippet': 'text', ctx: page.data }"
    ></card>
  </div>
</template>

<script>
  export default {
    name: 'about',
    data: () => ({
      title: 'About',
      body: 'here have some text'
    })
  }
</script>
