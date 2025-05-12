const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

// Email transporter configuration
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASSWORD
    }
});

exports.sendEmailNotification = functions.database
    .ref('/mail_notifications/{notificationId}')
    .onCreate(async (snapshot, context) => {
        const mailData = snapshot.val();
        
        if (!mailData || mailData.status !== 'pending') {
            return null;
        }

        const mailOptions = {
            from: process.env.EMAIL_USER,
            to: mailData.to,
            subject: mailData.subject,
            text: mailData.message
        };

        try {
            await transporter.sendMail(mailOptions);
            
            // Update status to sent
            await snapshot.ref.update({
                status: 'sent',
                sentAt: admin.database.ServerValue.TIMESTAMP
            });
            
            return null;
        } catch (error) {
            console.error('Error sending email:', error);
            
            // Update status to error
            await snapshot.ref.update({
                status: 'error',
                error: error.message
            });
            
            throw new functions.https.HttpsError('internal', 'Email sending failed');
        }
    }); 