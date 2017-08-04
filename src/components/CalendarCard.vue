<template>
  <div class="col-md-4">
    <b-card
       class="mb-2"
       header="gcal"
        :style="{ background: (idx % 2 === 0 ? '#fff' : '#eee'), color: 'black' }"
    >
      some stuff goes here
    </b-card>
  </div>
</template>

<script>
  import axios from 'axios'

  export default {
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

    name: 'calendar-card'
  }
</script>
