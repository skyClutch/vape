export default function getByPath(obj, path) {
  const steps = path.split('.')

  if (!path)
    return obj

  for (let i in steps) {
    let step = steps[i]

    if (typeof(obj) !== 'object')
      return undefined

    obj = obj[step]
  }

  return obj
}
