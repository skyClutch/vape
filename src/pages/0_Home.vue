<template>
  <div class="row">
    <jumbo-tron :title="title"></jumbo-tron>
    <card 
       :title="welcome.title"
       :text="welcome.text"
    ></card>
    <calendar-card></calendar-card>
    <div class="col-md-4">
    </div>
  </div>
</template>

<script>
  import axios from 'axios'
  export default {
    name: 'home',

    data() {
      return {
        title: 'Home',
        body: 'here have some text',
        welcome: { title: 'welcome', text: 'welcome text' }
      }
    }
  }
</script>
