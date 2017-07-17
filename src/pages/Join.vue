<template>
  <div> 
    <jumbo-tron :title="title" :img="img"></jumbo-tron>
    <hr /> 
    <p>{{body}}</p> </div>
</template>

<script>
  export default {
    name: 'join',
    data: () => ({
      parentId: 2,
      "title": "Join Our Team", 
      "img": "http://thecatapi.com/api/images/get?format=src&type=gif&size=med", 
      "body": `We need new board members for these positions:
          Santa Rosa & North Area Coordinator
        Diversity & Inclusion VP
      Student Board Member
      Communications VP`
    })
  }
</script>
