<template>
  <div> 
    <img :src="img"/>
    <hr /> 
    <p>{{body}}</p> </div>
</template>

<script>
  export default {
    name: 'welcome',
    data: () => ({
      parentId: 1,
      "title": "Welcome", 
      "img": "http://thecatapi.com/api/images/get?format=src&type=gif", 
      "body": `The 14th District PTA serves Sonoma, Mendocino, and Lake counties. We are comprised of 45 school PTas and have over 5,000 members. Our members are parents, administrators, teachers, students, and community members...`
    })
  }
</script>
