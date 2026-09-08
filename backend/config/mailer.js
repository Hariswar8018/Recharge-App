const nodemailer = require('nodemailer');

const mailTransporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST || 'mail.srdigitalseva.com',
  port: parseInt(process.env.SMTP_PORT) || 465,
  secure: true,
  auth: {
    user: process.env.SMTP_USER || 'no-reply@srdigitalseva.com',
    pass: process.env.SMTP_PASS || 'UseYourEmailPasswordHere!'
  }
});

async function sendNotificationEmail(to, subject, htmlContent) {
  try {
    await mailTransporter.sendMail({
      from: `"EarnFarm Support" <${process.env.SMTP_USER || 'no-reply@srdigitalseva.com'}>`,
      to,
      subject,
      html: htmlContent
    });
    console.log(`Notification email sent to ${to}: ${subject}`);
  } catch (err) {
    console.error('Failed to send notification email:', err);
  }
}

module.exports = {
  sendNotificationEmail
};
