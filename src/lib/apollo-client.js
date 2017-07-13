import 'isomorphic-fetch'
import ApolloClient, { createNetworkInterface } from 'apollo-client'
import { APP_URL } from '../../config'

const networkInterface = createNetworkInterface({
    uri: APP_URL
})

export default new ApolloClient({ networkInterface })
