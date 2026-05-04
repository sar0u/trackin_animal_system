package com.hbtech.cheptel.service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender mailSender;

    @Value("${spring.mail.username}")
    private String fromEmail;

    public boolean sendResetCode(String toEmail, String code) {
        try {
            MimeMessage message = mailSender.createMimeMessage();

            MimeMessageHelper helper = new MimeMessageHelper(
                    message,
                    MimeMessageHelper.MULTIPART_MODE_MIXED_RELATED,
                    "UTF-8"
            );

            helper.setFrom(fromEmail);
            helper.setTo(toEmail);
            helper.setSubject("DZcheptel — Code de réinitialisation");

            String html = buildEmailHtml(code);
            helper.setText(html, true);

            mailSender.send(message);

            System.out.println("✅ Email envoyé à : " + toEmail);

            return true;

        } catch (MessagingException e) {
            System.out.println("❌ Erreur envoi email : " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    private String buildEmailHtml(String code) {
        return """
            <!DOCTYPE html>
            <html>
            <head><meta charset="UTF-8"></head>
            <body style="font-family:Arial,sans-serif;background:#f7faf5;padding:30px;">
                <div style="max-width:500px;margin:auto;background:white;border-radius:16px;padding:40px;box-shadow:0 4px 20px rgba(0,0,0,0.1);">
                    <div style="text-align:center;margin-bottom:30px;">
                        <h2 style="color:#0B5D1E;margin:0;">DZcheptel</h2>
                        <p style="color:#666;margin-top:6px;">Plateforme de gestion du cheptel</p>
                    </div>
                   \s
                    <h3 style="color:#1f2a24;text-align:center;">Réinitialisation du mot de passe</h3>
                   \s
                    <p style="color:#444;text-align:center;">
                        Voici votre code de vérification :
                    </p>
                   \s
                    <div style="background:#EAF5E8;border-radius:12px;padding:20px;text-align:center;margin:24px 0;">
                        <span style="font-size:36px;font-weight:bold;color:#0B5D1E;letter-spacing:10px;">
                            %s
                        </span>
                    </div>
                   \s
                    <p style="color:#666;text-align:center;font-size:14px;">
                        Ce code expire dans <strong>15 minutes</strong>.
                    </p>
                   \s
                    <p style="color:#999;text-align:center;font-size:12px;">
                        Si vous n'avez pas demandé cette réinitialisation, ignorez cet email.
                    </p>
                   \s
                    <hr style="border:none;border-top:1px solid #eee;margin:24px 0;">
                   \s
                    <p style="color:#bbb;text-align:center;font-size:11px;">
                        © DZcheptel — Ministère de l'Agriculture
                    </p>
                </div>
            </body>
            </html>
           \s""".formatted(code);
    }
}