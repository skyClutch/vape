<template>
  <div class="col-md-4">
    <b-card
       class="mb-2"
       :style="{ background: (idx % 2 === 0 ? '#fff' : '#eee'), color: 'black' }"
    >
      <b-table striped hover small
        :items="items"
        :fields="fields"
      >
        <template slot="summary" scope="item">
          <a :href="item.item.htmlLink" target="_blank">
            {{item.value}}
          </a>
        </template>
        <template slot="date" scope="item">
          {{getDate(item)}}
        </template>
      </b-table>
      <clutch v-if="!items"></clutch>
    </b-card>
  </div>
</template>

<script>
  import axios from 'axios'

  export default {
    asyncData() {
      let calendarApi = `https://www.googleapis.com/calendar/v3/calendars/${this.calendarId}/events?key=${this.gapiKey}`

      return axios.get(calendarApi)
      .then(result => {
        console.log(result)
        return {
          items: result.data.items
        }
      })
      .catch(err => {
        console.log(err)
      })
    },

    data() {
      return {
        fields: {
          summary: {
            label: 'Agenda'
          },

          date:{
            label: ''
          }
        },

        items: null
      }
    },

    methods: {
      getDate(item) {
        try {
          let date = item.item.start.date || item.item.start.dateTime
          return date.split('T')[0].split('-').slice(1).join('/')
        }
        catch (err) {
          return ''
        }
      }
    },

    name: 'calendar-card',

    props: ['title', 'calendarId', 'gapiKey', 'idx']
  }
</script>

<style scoped lang="stylus">
  .card
    border-radius 0px
    border none
    max-height 600px
    background #eee !important
    overflow auto
    opacity: 0.8

  .card:hover
    background #eee !important
    color: black !important
    opacity: 0.9
</style>
