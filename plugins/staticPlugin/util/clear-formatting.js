import sanitizeHtml from 'sanitize-html'

export default function sanitize(dirty) {
  return sanitizeHtml(dirty, {
      transformTags     : {
        'h1' : 'h3',
        'h2' : 'h4'
      }
  });
}
