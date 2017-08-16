const config = require('../config/server')

const nodemailer = require('nodemailer')

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: config.GMAIL_USERNAME,
    pass: config.GMAIL_PASSWORD
  }
})

module.exports = function (req, res, next) {
  const mailOptions = {
    to: config.GMAIL_USERNAME,
    subject: 'Website Contact Form',
    text: `
      name: ${req.body.name}
      email: ${req.body.email}
      message: 
        ${req.body.message}
      `
  }

  transporter.sendMail(mailOptions, function(error, info){
    if (error) {
      console.log(error)
    } else {
      console.log('Email sent: ' + info.response)
    }

    res.send('Email Sent')
  })
}
