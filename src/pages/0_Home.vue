<template>
  <div class="row">
    <jumbo-tron :title="title"></jumbo-tron>
    <card 
       :title="welcome.title"
       :text="welcome.text"
       size="8"
       v-static="{ '.snippet': 'text', '.card-title': 'title', ctx: welcome }"
       :idx="0"
       ></card>
    <card 
       :title="announcements.title"
       :text="announcements.text"
       size="4"
       v-static="{ '.snippet': 'text', '.card-title': 'title', ctx: announcements }"
       :idx="1"
       ></card>
    <contact-card></contact-card>
  </div>  
</template>

<script>
  export default {
    data() {
      return {
        title: 'Home',
        body: 'here have some text',
        welcome: { title: 'welcome', text: 'welcome text' },
        announcements: { title: 'Announcements', text: 'announcements text' }
      }
    },

    name: 'home'
  }
</script>
