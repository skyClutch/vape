<template>
  <div> 
    <jumbo-tron :title="title" :img="img"></jumbo-tron>
    <hr /> 
    <p>{{body}}</p> </div>
</template>


<script>
  export default {
    name: 'board',
    data: () => ({
      parentId: 2,
      "title": "Board", 
      "img": "http://thecatapi.com/api/images/get?format=src&type=gif&size=med", 
      "body": ` Abby Fellman - President 
      Michelle Wing - Treasurer
      Elizabeth Smith- Secretary/ Membership/ Historian
      Trish Luna - Leadership VP/ Coast Area Coordinator
      Christal Barquero- Programming VP / Reflections / Santa Rosa & North Area Coordinator
      Nicole Turner - Rohnert Park / Cotati Area Coordinato
      Samantha Bolinger - Petaluma Area Coordinator`
    })
  }
</script>
