import 'isomorphic-fetch'
import ApolloClient, { createNetworkInterface } from 'apollo-client'
import { APP_URL } from '../client/config'

const isBrowser = typeof window !== 'undefined'
const client = isBrowser ? createApolloClient() : null

export default function getApolloClient() {
  if (isBrowser)
    return client
  else
    return createApolloClient()
}

function createApolloClient() {
  const networkInterface = createNetworkInterface({
      uri: `${APP_URL}/graphql`,
  })

	console.log('making new client')

  return new ApolloClient({ networkInterface })
}
