<template>
  <div v-static="{ h2: 'title', 'div.backdrop': 'body' }"> 
    <jumbo-tron :title="title" :img="img"></jumbo-tron>
    <div class="backdrop" v-html="body"></div> 
  </div>
</template>

<script>
  export default {
    name: 'join',
    data: () => ({
      parentId: 2,
      "title": "Join Our Team", 
      "img": "http://thecatapi.com/api/images/get?format=src&type=gif&size=med", 
      "body": `We need new board members for these positions: <ul> <li>Santa Rosa & North Area Coordinator</li> <li>Diversity & Inclusion VP</li> <li>Student Board Member</li> <li>Communications VP</li> </ul>`
    })
  }
</script>
