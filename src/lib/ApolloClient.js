import 'isomorphic-fetch'
import ApolloClient, { createNetworkInterface } from 'apollo-client'
import { APP_URL } from '../client/config'

const inBrowser = typeof window !== 'undefined';
const networkInterface = createNetworkInterface({
    uri: `${APP_URL}/graphql`,
    // all updates are sent from the client, so we skip the cache on the server
    fetchPolicy: inBrowser ? 'cache-first' : 'network-only'
})

export default new ApolloClient({ networkInterface })
