<template>
  <div> 
    <jumbo-tron :title="title" :img="img"></jumbo-tron>
    <div class="backdrop" v-html="body"></div>
  </div>
</template>

<script>
  export default {
    name: 'units',
    data: () => ({
      parentId: 2,
      "title": "Our Units", 
      "img": "http://thecatapi.com/api/images/get?format=src&type=gif&size=med", 
      "body": `Here, have some units!`
    })
  }
</script>
