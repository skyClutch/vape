<template>
  <div class="row">
    <jumbo-tron :title="title"></jumbo-tron>
    <card 
       :title="welcome.title"
       :text="welcome.text"
    ></card>
    <div class="col-md-4">
    </div>
  </div>
</template>

<script>
  import axios from 'axios'
  export default {
    name: 'home',

    asyncData() {
      let calendarApi = 'https://www.googleapis.com/calendar/v3/calendars/upmrabbvo4kpri3tin7uu1475g@group.calendar.google.com/events?key=AIzaSyCnZX7lHTEYhBT8SmudcZnB-vthC5b6sfo'

      console.trace('asyncData')
      return axios.get(calendarApi)
      .then(data => {
        console.log(data)
      })
      .catch(err => {
        console.log(err)
      })
    },

    data: () => ({
      title: 'Home',
      body: 'here have some text',
      welcome: { title: 'welcome', text: 'welcome text' }
    })
  }
</script>
