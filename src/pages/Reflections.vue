<template>
  <div> 
    <jumbo-tron :title="title" :img="img"></jumbo-tron>
    <hr /> 
    <div v-html="body"></div>
  </div>
</template>

<script>
  export default {
    name: 'reflections',
    data: () => ({
      parentId: 6,
      "title": "Reflections", 
      "img": "http://thecatapi.com/api/images/get?format=src&type=gif&size=med", 
      "body":`<p>PTA Reflections is a nationally acclaimed student recognition program to encourage artistic creativity in the classroom and at home. Students of all grades and abilities may participate and explore the arts based on the 2017-2018 theme: Within Reach.</p>

      <p>To participate, contact your Local/State PTA for official program rules and deadlines.</p>

      <p>Students may choose one or all of the available arts categories:</p>

      <ul style="list-style: none;">
        <li><img src="/public/reflections/dance.png"/> <strong>Dance Choreography</strong></li>
        <li><img src="/public/reflections/film.png"/> <strong>Film Production</strong></li>
        <li><img src="/public/reflections/literature.png"/> <strong>Literature</strong></li>
        <li><img src="/public/reflections/music.png"/> <strong>Music Composition</strong></li>
        <li><img src="/public/reflections/photography.png"/> <strong>Photography</strong></li>
        <li><img src="/public/reflections/visual-arts.png"/> <strong>Visual Arts</strong></li>
      </ul>

      <p>The arts—and the National PTA Reflections program—s upport student success and serve as a valuable tool for building strong partnerships in your school community. Celebrate arts learning in your school community with Reflections.</p>`
    })
  }
</script>
