<template>
  <div class="row">
    <jumbo-tron :title="title"></jumbo-tron>
    <card v-for="(page, idx) in children" :key="page.id"
      :text="page.data.body"
      :img="page.data.img"
      :title="page.data.title"
      :sub-title="page.data.subTitle"
      :idx="idx"
      v-static="{ '.card-title': 'title', '.snippet': 'body', list: children, ctx: page.data }"
    ></card>
    <list-control list="children" :blueprint="{ data: { title: 'title', body: 'card body' } }"></list-control>
  </div>
</template>

<script>
  export default {
    name: 'about',
    data: () => ({
      title: 'About',
      body: 'here have some text',
      children: []
    })
  }
</script>
