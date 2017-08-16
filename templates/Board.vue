<template>
  <div v-static="{ h2: 'title', 'div.backdrop': 'body' }"> 
    <jumbo-tron :title="title" :img="img"></jumbo-tron>
    <div class="backdrop" v-html="body"> </div>
  </div>
</template>

<script>
  export default {
    name: 'board',
    data: () => ({
      parentId: 2,
      "title": "Board", 
      "img": "http://thecatapi.com/api/images/get?format=src&type=gif&size=med", 
      "body": `<ul> 
      <li>Abby Fellman - President </li>
      <li>Michelle Wing - Treasurer</li>
      <li>Elizabeth Smith- Secretary/ Membership/ Historian</li>
      <li>Trish Luna - Leadership VP/ Coast Area Coordinator</li>
      <li>Christal Barquero- Programming VP / Reflections / Santa Rosa & North Area Coordinator</li>
      <li>Nicole Turner - Rohnert Park / Cotati Area Coordinato</li>
      <li>Samantha Bolinger - Petaluma Area Coordinator</li>
      </ul>`
    })
  }
</script>
