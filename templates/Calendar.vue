<template>
  <div class="row">
    <jumbo-tron :title="title"></jumbo-tron>
    <div class="col-md-12">
      <iframe src="https://calendar.google.com/calendar/embed?height=600&amp;wkst=1&amp;bgcolor=%23FFFFFF&amp;src=upmrabbvo4kpri3tin7uu1475g%40group.calendar.google.com&amp;color=%238D6F47&amp;ctz=America%2FLos_Angeles" style="border-width:0" width="100%" height="600" frameborder="0" scrolling="no"></iframe>
    </div>
    <!-- <calendar-card
      calendarId="upmrabbvo4kpri3tin7uu1475g@group.calendar.google.com"
      gapiKey="AIzaSyCnZX7lHTEYhBT8SmudcZnB-vthC5b6sfo"
      :idx="1"
    ></calendar-card> -->
  </div>
</template>

<script>
  export default {
    data() {
      return {
        title: 'Calendar',
        body: 'here have a calendar',
      }
    },

    name: 'calendar'
  }
</script>

<style lang="stylus" scoped>
  .col-md-8
    padding 0px
</style>
