const nodemailer = require('nodemailer');
require('dotenv').config({ path: __dirname + '/../.env' });

async function main() {
  console.log('Reading SMTP configuration...');
  console.log('Host:', process.env.SMTP_HOST);
  console.log('Port:', process.env.SMTP_PORT);
  console.log('User:', process.env.SMTP_USER);
  console.log('Pass:', process.env.SMTP_PASS ? '******** (Loaded)' : 'Not Set');

  if (!process.env.SMTP_PASS || process.env.SMTP_PASS === 'YOUR_EMAIL_PASSWORD_HERE') {
    console.error('\nERROR: Please fill in your SMTP_PASS inside the backend/.env file first!');
    process.exit(1);
  }

  const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: parseInt(process.env.SMTP_PORT),
    secure: true,
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS
    }
  });

  console.log('\nSending test email to hariswarsamasi@gmail.com...');
  try {
    const info = await transporter.sendMail({
      from: `"EarnFarm Test" <${process.env.SMTP_USER}>`,
      to: 'hariswarsamasi@gmail.com',
      subject: 'SMTP Integration Success! - EarnFarm',
      html: `
        <h2>SMTP Connection Working!</h2>
        <p>This email verifies that your Node.js backend can successfully connect to <strong>${process.env.SMTP_HOST}</strong> using your credentials and send emails.</p>
        <p>Sent at: ${new Date().toLocaleString()}</p>
      `
    });

    console.log('Email sent successfully! Message ID:', info.messageId);
  } catch (err) {
    console.error('Failed to send email:', err);
  }
}

main();
