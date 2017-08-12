<template>
  <div class="col-md-8">
    <b-card
       title="Contact Us"
       class="mb-2"
       >
     <b-alert dismissable variant="danger" v-for="error in errors" :key="error" :show="!!errors.length">
       {{error}}
     </b-alert>
     <b-alert dismissable variant="success" :show="!!success">
       {{success}}
     </b-alert>
      <b-form-input
        v-model="name"
        type="text"
        placeholder="Enter your name"
      ></b-form-input>
      <b-form-input
        v-model="email"
        type="text"
        placeholder="Enter your email"
      ></b-form-input>
      <b-form-input textarea 
        :rows="5"
        v-model="message"
        placeholder="Enter your message"
      ></b-form-input>
      <b-button @click="sendMail">Send</b-button>
    </b-card>
  </div>
</template>

<script>
  import axios from 'axios'

  export default {
    data() {
      return {
        email: '',
        errors: [],
        message: '',
        name:    '',
        success: ''
      }
    },

    methods: {
      sendMail() {
        const re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

        this.errors = []

        if (!this.name)
          this.errors.push('Please enter your name')

        if (!this.message)
          this.errors.push('Please enter a message')

        if (!re.test(this.email))
          this.errors.push('Please enter a valid email address')

        if (this.errors.length)
          return

        axios.post('/mail', {
          name: this.name,
          email: this.email,
          message: this.message
        })
        // TODO add error handling
        .then(response => {
          this.success = response.data
          this.message = ''
          this.email   = ''
          this.name    = ''
        })
      }
    },

    name: 'contact-card'
  }
</script>

<style scoped lang="stylus">
  .col-md-8
    padding-left 0px !important
    padding-right 0px !important

  .card
    border-radius 0px
    border none
    color black
    max-height 600px
    background #eee !important
    overflow auto
    opacity 0.8

  .card:hover
    background #eee !important
    color: black !important
    opacity: 0.9
</style>
