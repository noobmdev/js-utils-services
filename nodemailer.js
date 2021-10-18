const nodemailer = require("nodemailer");

const config = {
  SMTP_HOST: "smtp.ethereal.email",
  SMTP_PORT: 587,
  SMTP_USERNAME: "123456khj001@gmail.com",
  SMTP_PASSWORD: "Panel213@@",
  EMAIL_FROM: "123456khj001@gmail.com",
  EMAIL_TO: "manuci1801@gmail.com",
  SUBJECT: "subject",
  TEXT: "text",
};

const main = () => {
  const transport = nodemailer.createTransport({
    // host: config.SMTP_HOST,
    // port: config.SMTP_PORT,
    service: "gmail",
    host: "smtp.gmail.com",
    auth: {
      user: config.SMTP_USERNAME,
      pass: config.SMTP_PASSWORD,
    },
  });

  return transport.sendMail({
    to: config.EMAIL_TO,
    from: config.EMAIL_FROM,
    subject: config.SUBJECT,
    text: config.TEXT,
  });
};

main().then(console.log).catch(console.log);
