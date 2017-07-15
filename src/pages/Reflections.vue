<template>
  <div> 
    <jumbo-tron :title="title" :img="img"></jumbo-tron>
    <hr /> 
    <p>{{body}}</p> </div>
</template>

<script>
  export default {
    name: 'reflections',
    data: () => ({
      parentId: 2,
      "title": "Reflections", 
      "img": "http://thecatapi.com/api/images/get?format=src&type=gif&size=med", 
      "body":`PTA Reflections is a nationally acclaimed student recognition program to encourage artistic creativity in the classroom and at home. Students of all grades and abilities may participate and explore the arts based on the 2017-2018 theme: Within Reach

      To participate, contact your Local/State PTA for official program rules and deadlines.

          Students may choose one or all of the available arts categories:

      Dance Choreography
      Film Production
      Literature
      Music Composition
      Photography
      Visual Arts

      The arts—and the National PTA Reflections program—s upport student success and serve as a valuable tool for building strong partnerships in your school community. Celebrate arts learning in your school community with Reflections.`
    })
  }
</script>
