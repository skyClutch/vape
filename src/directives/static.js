import setByPath from '../util/setByPath'

export default {
  // When the bound element is inserted into the DOM...
  bind(el, binding, vnode) {
    el.addEventListener('click', (evt) => {
      evt.preventDefault()
      if (el.dataset.editing === "true")
        return

      el.dataset.editing = true
      evt.stopPropagation()
      for (let selector in binding.value) {
        let path = binding.value[selector]
        if (selector === 'path') {
          setEditable(el, el, path, vnode.context.$store.state.page.data)
        } else {
          el.querySelectorAll(selector).forEach(child => {
            setEditable(el, child, path, vnode.context.$store.state.page.data)
          })
        }
      }
    })
  }
}

function setEditable(el, child, path, dataObj) {
  // make it obvious
  child.contentEditable   = true
  child.style.borderWidth = '1px'
  child.style.borderColor = 'black'
  child.style.borderStyle = 'solid'

  // don't let them disappear
  if (child.innerText.trim() === '')
    child.innerText = randomPlaceHolder()

  // save on blur
  child.addEventListener('blur', evt => {
    setByPath(dataObj, path, child.innerText)
    child.contentEditable = false
    child.style.borderWidth = ''
    child.style.borderColor = ''
    child.style.borderStyle = ''
    el.dataset.editing = false;
  })
}

function randomPlaceHolder() {
  const placeholders = [
    'fill me up',
    'write me in',
    'place some witty text here',
    'placeholder'
  ]

  return placeholders[Math.floor(Math.random() * placeholders.length)]
}
