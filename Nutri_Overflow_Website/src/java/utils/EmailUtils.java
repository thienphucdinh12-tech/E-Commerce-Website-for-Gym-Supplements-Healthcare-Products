package utils;

import java.util.Properties;
import javax.mail.*;
import javax.mail.internet.*;

public class EmailUtils {
    // SMTP Configuration constants (update these with your own credentials)
    private static final String HOST = "smtp.gmail.com";
    private static final String PORT = "465";
    private static final String SENDER_EMAIL = "anhquan06w@gmail.com"; 
    private static final String SENDER_PASSWORD = "yfvdwvdapssvxnfd";    

    public static boolean sendVerificationCode(String toEmail, String code) {
        // ALWAYS print verification code to Tomcat logs/Console for ease of testing
        System.out.println("==============================================");
        System.out.println("VERIFICATION CODE FOR " + toEmail + ": " + code);
        System.out.println("==============================================");

        Properties prop = new Properties();
        prop.put("mail.smtp.host", HOST);
        prop.put("mail.smtp.port", PORT);
        prop.put("mail.smtp.auth", "true");
        prop.put("mail.smtp.ssl.enable", "true");
        prop.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
        prop.put("mail.smtp.socketFactory.port", PORT);
        prop.put("mail.smtp.ssl.protocols", "TLSv1.2");
        
        Session session = Session.getInstance(prop, new javax.mail.Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(SENDER_EMAIL, "NutriOverflow Support"));
            message.setRecipients(
                    Message.RecipientType.TO,
                    InternetAddress.parse(toEmail)
            );
            message.setSubject("Ma xac nhan dang ky tai khoan - NutriOverflow");
            
            String htmlContent = "<h3>Chao ban,</h3>"
                    + "<p>Cam on ban da dang ky tai khoan tai NutriOverflow.</p>"
                    + "<p>Ma xac nhan cua ban la: <strong style='font-size: 18px; color: #00e676;'>" + code + "</strong></p>"
                    + "<p>Ma nay co hieu luc trong vong 5 phut. Vui long khong chia se ma nay voi bat ky ai.</p>"
                    + "<br/>"
                    + "<p>Tran trong,</p>"
                    + "<p>Doi ngu NutriOverflow</p>";
            
            message.setContent(htmlContent, "text/html; charset=UTF-8");

            Transport.send(message);
            return true;
        } catch (Exception e) {
            System.err.println("Email delivery failed: " + e.getMessage() + ". Please configure valid SMTP credentials in EmailUtils.java.");
            e.printStackTrace();
            return false;
        }
    }
}
