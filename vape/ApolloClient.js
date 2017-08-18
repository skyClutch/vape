import 'isomorphic-fetch'
import ApolloClient, { createNetworkInterface } from 'apollo-client'
import { APP_URL } from '../config/client'

const authMiddleware = [{
  applyMiddleware(req, next) {
    if (!req.options.headers)
      req.options.headers = {}  // Create the header object if needed.

    if (localStorage.getItem('authToken'))
      req.options.headers['authorization'] =  `Bearer ${localStorage.getItem('authToken')}`

    next()
  }
}]
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
    credentials: 'same-origin'
  })

  if (isBrowser)
    networkInterface.use(authMiddleware)

  return new ApolloClient({ networkInterface })
}

