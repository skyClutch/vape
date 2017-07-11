<template>
  <div>
    <card v-for="card in cards" :key="card.title"
      v-bind:text="card.text"
      v-bind:img="card.img"
      v-bind:title="card.title"
      v-bind:sub-title="card.subTitle"
      v-bind:overlay=card.overlay
      v-bind:footer=card.footer
    ></card>
  </div>
</template>

<script>
  export default {
    name: 'home',

    data() {
      return {
        cards: [
          {
            title: 'Welcome!',
            img: 'http://thecatapi.com/api/images/get?format=src&type=gif',
            overlay: true,
            text: 'The 14th District PTA serves Sonoma, Mendocino, and Lake counties. We are comprised of 45 school PTas and have over 5,000 members. Our members are parents, administrators, teachers, students, and community members...'
          }
        ]
      }
    }
  }
</script>
