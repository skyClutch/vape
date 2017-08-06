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
    <calendar-card
      calendarId="upmrabbvo4kpri3tin7uu1475g@group.calendar.google.com"
      gapiKey="AIzaSyCnZX7lHTEYhBT8SmudcZnB-vthC5b6sfo"
      :idx="1"
    ></calendar-card>
  </div>
</template>

<script>
  export default {
    data() {
      return {
        title: 'Home',
        body: 'here have some text',
        welcome: { title: 'welcome', text: 'welcome text' }
      }
    },

    name: 'home'
  }
</script>
