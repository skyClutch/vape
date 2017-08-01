import Vue from 'vue'

export default function deleteByPath(obj, path, val) {
  const steps = path.split('.')

  if (!path)
    return obj

  for (let i = 0; i < steps.length - 1; i++) {
    let step = steps[i]

    if (typeof(obj) !== 'object')
      return

    obj = obj[step]
  }

  if (Array.isArray(obj))
    obj.splice(steps[steps.length - 1], 1)
  else
    Vue.delete(obj, steps[steps.length - 1])
}
