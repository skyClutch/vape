import sanitizeHtml from 'sanitize-html'

/**
 * sanitizes html using the sanitize-html package with our options
 * @param {string} dirty - dirty html
 * @returns {string} - cleaned html
 */
export default function sanitize(dirty) {
  let allowedAttributes = Object.assign({ 'span': [] }, sanitizeHtml.defaults.allowedAttributes)
  let allowedTags = sanitizeHtml.defaults.allowedTags.concat([ 'span' ])

  // allow styling
  for (let i in allowedTags) {
    let tagName = allowedTags[i]
    allowedAttributes[tagName] = allowedAttributes[tagName] || []
    allowedAttributes[tagName] = allowedAttributes[tagName].concat(['style'])
  }

  return sanitizeHtml(dirty, {
      allowedTags       : allowedTags,
      allowedAttributes : allowedAttributes,
      transformTags     : {
        'h1' : 'h3',
        'h2' : 'h4'
      }
  })
}
