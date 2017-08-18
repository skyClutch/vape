import Vue from 'vue'

export default function setByPath(obj, path, val) {
  const steps = path.split('.')

  if (!path)
    return obj

  for (let i = 0; i < steps.length - 1; i++) {
    let step = steps[i]

    if (typeof(obj) !== 'object')
      return

    obj = obj[step]
  }

  Vue.set(obj, steps[steps.length - 1], val)
}
