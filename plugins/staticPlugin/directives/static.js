import { sanitize, clearFormatting } from '../util'
import { getByPath } from '../../../vape/util'
import Vue from 'vue'

// space to save current el, binding, vnode and ctx
const state = { spans: [] }

export default {
  bind(el, binding, vnode) {
    // make specified elements editable when clicking
    el.addEventListener('click', (evt) => {
      // if we are not in edit mode do nothing
      if (!vnode.context.$store.state.editing)
        return

      // stop default behaviors
      evt.preventDefault()
      evt.stopPropagation()

      // don't reset if we're currently editing this set of elements
      if (el.dataset.editing)
        return

      // unset and set editable elements if switching to new set
      unsetEditables()
      setEditables(el, binding, vnode)
    })
  }
}

function addCFButton(child) {
  // add clear format button
  let span = document.createElement('span')
  span.className = 'v-static-clear-format-button'
  span.innerHTML = '<button class="btn btn-sm" alternate="clear formatting">cF</button>'
  child.parentNode.insertBefore(span, child.nextSibling)
  span.addEventListener('click', evt => {
    span.remove()
    child.focus()
    child.dataset.oldHTML = child.dataset.oldHTML || child.innerHTML
    child.innerHTML = clearFormatting(child.innerHTML)
    addRFButton(child)
  })
  state.spans.push(span)
}

function addRFButton(child) {
  // add restore format button
  let span = document.createElement('span')
  span.className = 'v-static-restore-format-button'
  span.innerHTML = '<button class="btn btn-sm" alternate="restore formatting">rF</button>'
  child.parentNode.insertBefore(span, child.nextSibling)
  span.addEventListener('click', evt => {
    span.remove()
    child.focus()
    child.innerHTML = child.dataset.oldHTML
    addCFButton(child)
  })
  state.spans.push(span)
}

function blurHandler(evt) {
  // don't let them disappear
  if (this.innerText.trim() === '')
    this.innerText = getRandomPlaceHolder()

  while (state.spans.length) {
    state.spans.shift().remove()
  }
  // clean html
  let clean = sanitize(this.innerHTML)

  // save the data
  state.vnode.context.setStatic(this.dataset.path, clean, state.ctx)

  // add listener for document and curent parent el
  state.el.addEventListener('click', nextClick)
}

// handle events after blur
function nextClick(evt) {
  // if the event hits the current parent element don't let bubble to document
  if (this.dataset && this.dataset.editing)
    evt.stopPropagation()
  // if click triggered elsewhere unset current elements
  else
    unsetEditables()

  // keep listeners from piling up
  state.el.removeEventListener('click', nextClick)
  document.removeEventListener('click', nextClick)
}

function setEditable(el, child, path, binding, vnode, ctx) {
  // make it obvious
  child.contentEditable    = true
  child.style.borderWidth  = '1px'
  child.style.borderColor  = 'black'
  child.style.borderStyle  = 'solid'
  child.style.borderRadius = '.2em'
  child.dataset.editing    = true
  child.dataset.path       = path

  addCFButton(child)

  // save on blur
  child.addEventListener('blur', blurHandler)

  // add click event to doc
  document.addEventListener('click', nextClick)
}

function setEditables(el, binding, vnode) {
  el.dataset.editing = true

  // set context
  let ctx = binding.value.ctx

  // save for clearing next time
  Object.assign(state, { el, binding, vnode, ctx })

  // iterate through v-static value
  for (let selector in binding.value) {
    let path = binding.value[selector]

    // we've already set the ctx
    if (selector === 'ctx') {
      continue
    }
    // path for making el editable, no children
    else if (selector === 'path') {
      setEditable(el, el, path, binding, vnode, ctx)
    } 
    // if we have a list, add list controls
    else if (selector === 'list') {
      let span = document.createElement('span')
      span.className = 'list-item-control'
      el.prepend(span)
      state.vm = new Vue({
        el: span,
        template: '<list-item-control list="list" item="item"></list-item-control>',
        parent: vnode.context,
        provide: {
          list: path,
          item: ctx
        }
      })
    } 
    // add hidden elements
    else if (selector === 'hidden') {
      let editables = el.querySelectorAll('[contenteditable=true]')
      let editableParent = editables[editables.length - 1].parentNode

      let hidden = document.createElement('strong')
      hidden.className = 'v-static-hidden'
      hidden.innerHTML = 'hidden:'

      editableParent.appendChild(hidden)

      path.forEach(prop => {
        let className = `v-static-hidden-${prop}`
        let p = document.createElement('p')

        p.className = className
        p.innerHTML = getByPath(ctx, prop) || prop

        editableParent.appendChild(p)

        setEditable(el, el.querySelector(`p.${className}`), prop, binding, vnode, ctx)
      })
    }
    // if we have a normal selector, make element editable
    else {
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
    delete child.dataset.path
    child.removeEventListener('blur', blurHandler)
}

function unsetEditables() {
  let { el, binding, vnode, spans } = state

  if (!el || !binding || !vnode)
    return

  while (spans.length) {
    spans.shift().remove()
  }

  for (let selector in binding.value) {
    let path = binding.value[selector]
    // unset el if no children
    if (selector === 'path') {
      unsetEditable(el)
    // remove list controls
    } else if (selector === 'list') {
      if (state.vm) {
        state.vm.$el.remove()
        state.vm.$destroy()
      }
    // remove hidden elements
    } else if (selector === 'hidden') {
      let hidden = el.querySelector('.v-static-hidden')

      if (hidden)
        hidden.remove()

      path.forEach(prop => {
        let className = `v-static-hidden-${prop}`
        let hiddenProp = el.querySelector(`.${className}`)
        
        if (hiddenProp)
          hiddenProp.remove()
      })
    // remove normal children
    } else {
      el.querySelectorAll(selector).forEach(child => {
        unsetEditable(child)
      })
    }
  }

  // unset editing flag
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
