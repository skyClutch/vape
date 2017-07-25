const state = {}

if (typeof document !== 'undefined') {
  document.addEventListener('click', evt => {
    if (!evt.target.dataset.editing)
      unsetEditables()
  })
}

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

function setEditable(el, child, path, binding, vnode, ctx) {
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

    vnode.context.setStatic(path, child.innerText, ctx)
  })
}

function setEditables(el, binding, vnode) {
  // save for clearing next time
  Object.assign(state, { el, binding, vnode })

  el.dataset.editing = true

  let ctx = binding.value.ctx

  for (let selector in binding.value) {
    let path = binding.value[selector]

    if (selector === 'ctx') {
      continue
    }
    if (selector === 'path') {
      setEditable(el, el, path, binding, vnode, ctx)
    } else {
      el.querySelectorAll(selector).forEach(child => {
        setEditable(el, child, path, binding, vnode, ctx)
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
