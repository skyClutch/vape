<template>
  <div> 
    <jumbo-tron :title="title" :img="img"></jumbo-tron>
    <div class="backdrop" v-html="body"></div>
  </div>
</template>


<script>
  export default {
    name: 'mission-statement',
    data: () => ({
      parentId: 2,
      "title": "Mission Statement", 
      "img": "http://thecatapi.com/api/images/get?format=src&type=gif&size=med", 
      "body": `The mission of the 14th district is to improve the education, health, and well being of the children and families and Sonoma, Mendocino, and Lake County by advocating for cultivating and empowering units.`
    })
  }
</script>
