<template>
  <div class="col-md-6 col-offset-3">
    <b-card>
      <b-form-input
        v-model="email"
        type="text"
        placeholder="Enter your email"
      ></b-form-input>
      <b-form-input
        v-model="password"
        type="password"
        placeholder="Enter your password"
      ></b-form-input>
      <b-button variant="primary" @click="login">Login</b-button>
    </b-card>
  </div>
</template>

<script>
  import apollo from '../vape/ApolloClient'
  import gql from 'graphql-tag'

  export default {
    data() {
      return {
        email: '',
        password: ''
      }
    },

    methods: {
      login() {
        return apollo().mutate({
          mutation: gql`
            mutation ($email: String!, $password: String!) {
              authenticate(input: {
                email: $email,
                password: $password
              }) {
                clientMutationId
                jwtToken
              }
            }
          `,
          variables: {
            email    : this.email,
            password : this.password
          }
        })
        .then(result => {
          localStorage.setItem('authToken', result.data.authenticate.jwtToken)
          window.location = window.location
        })
      }
    },

    name: 'login'
  }
</script>
