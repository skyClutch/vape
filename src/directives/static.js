import setByPath from '../util/setByPath'
import apollo from '../lib/ApolloClient'
import gql from 'graphql-tag'

const state = {}

export default {
  bind(el, binding, vnode) {

    el.addEventListener('click', (evt) => {
      evt.preventDefault()

      if (el.dataset.editing)
        return

      evt.stopPropagation()
      unsetEditables()
      setEditables(el, binding, vnode)
    })
  }
}

function setEditable(el, child, path, binding, vnode) {
  let page    = vnode.context.$store.state.page

  // make it obvious
  child.contentEditable    = true
  child.style.borderWidth  = '1px'
  child.style.borderColor  = 'black'
  child.style.borderStyle  = 'solid'
  child.style.borderRadius = '.2em'
  child.dataset.editing    = true

  // save on blur
  child.addEventListener('blur', evt => {
    // don't let them disappear
    if (child.innerText === '')
      child.innerText = getRandomPlaceHolder()

    setByPath(page.data, path, child.innerText)
    savePageData(page)

    if (!evt.target.dataset.editing)
      unsetEditables()
  })
}

function setEditables(el, binding, vnode) {
  // save for clearing next time
  Object.assign(state, { el, binding, vnode })

  el.dataset.editing = true

  for (let selector in binding.value) {
    let path = binding.value[selector]

    if (selector === 'path') {
      setEditable(el, el, path, binding, vnode)
    } else {
      el.querySelectorAll(selector).forEach(child => {
        setEditable(el, child, path, binding, vnode)
      })
    }
  }
}

function unsetEditable(child) {
    child.contentEditable    = false
    child.style.borderWidth  = ''
    child.style.borderColor  = ''
    child.style.borderStyle  = ''
    child.style.borderRadius = ''
    delete child.dataset.editing
}

function unsetEditables() {
  let { el, binding, vnode } = state

  if (!el || !binding || !vnode)
    return

  for (let selector in binding.value) {
    let path = binding.value[selector]
    if (selector === 'path') {
      unsetEditable(el)
    } else {
      el.querySelectorAll(selector).forEach(child => {
        unsetEditable(child)
      })
    }
  }

  delete el.dataset.editing
}

function getRandomPlaceHolder() {
  const placeholders = [
    'fill me up',
    'write me in',
    'place some witty text here',
    'placeholder'
  ]

  return placeholders[Math.floor(Math.random() * placeholders.length)]
}

function savePageData(page) {
  let json = JSON.stringify(page.data)
  
  return apollo().mutate({
    mutation: gql`mutation ($id: Int!, $data: Json) {
      updatePageById(input: {id: $id, pagePatch: {
        data: $data
      }
      }){page {id, data}}
    }`,
    variables: {
      id: page.id,
      data: json
    }
  })
  .then(result => {
    console.log(result)
  })
}
