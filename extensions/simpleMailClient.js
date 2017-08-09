const config = require('../src/server/config')

const nodemailer = require('nodemailer')

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: config.GMAIL_USERNAME,
    pass: config.GMAIL_PASSWORD
  }
})

const mailOptions = {
  to: 'john.fellman@gmail.com',
  subject: 'Sending Email using Node.js',
  text: 'That was easy!'
};

module.exports = function (req, res, next) {
  transporter.sendMail(mailOptions, function(error, info){
    if (error) {
      console.log(error)
    } else {
      console.log('Email sent: ' + info.response)
    }

    res.send('Email Sent')
  })
}
