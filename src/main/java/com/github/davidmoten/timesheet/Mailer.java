package com.github.davidmoten.timesheet;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.Date;
import java.util.Properties;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import javax.activation.DataHandler;
import javax.activation.DataSource;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;
import javax.mail.util.ByteArrayDataSource;

import com.google.common.base.Preconditions;

public class Mailer {

	public void sendZippedTimesToEmailAsAttachment(String timesTabDelimited, String email) {
		Preconditions.checkNotNull(email, "email parameter cannot be null");

		try {
			Properties props = new Properties();
			Session session = Session.getDefaultInstance(props, null);

			String msgBody = "Attached please find export of timesheet data.";

			Message msg = new MimeMessage(session);
			msg.setFrom(new InternetAddress("noreply@"
					+ System.getProperty("appengine.app.name")
					+ ".appspotmail.com", null));
			msg.addRecipient(Message.RecipientType.TO, new InternetAddress(
					email, null));
			msg.setSubject("Timesheet export " + new Date());

			// construct the text body part
			MimeBodyPart textBodyPart = new MimeBodyPart();
			textBodyPart.setText(msgBody);

			// construct the body part
			DataSource dataSource = new ByteArrayDataSource(
					getExportZippedBytes(timesTabDelimited), "application/zip");
			MimeBodyPart bodyPart = new MimeBodyPart();
			bodyPart.setDataHandler(new DataHandler(dataSource));
			bodyPart.setFileName("times.zip");

			// construct the mime multi part
			MimeMultipart mimeMultipart = new MimeMultipart();
			mimeMultipart.addBodyPart(textBodyPart);
			mimeMultipart.addBodyPart(bodyPart);

			msg.setContent(mimeMultipart);
			Transport.send(msg);
		} catch (MessagingException e) {
			throw new RuntimeException(e);
		} catch (UnsupportedEncodingException e) {
			throw new RuntimeException(e);
		}

	}

	private byte[] getExportZippedBytes(String timesTabDelimited) {
		ByteArrayOutputStream bytes = new ByteArrayOutputStream();
		ZipOutputStream zos = new ZipOutputStream(bytes);
		try {
			zos.putNextEntry(new ZipEntry("times.txt"));
			zos.write(timesTabDelimited.getBytes("UTF-8"));
			zos.closeEntry();
			zos.close();
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
		return bytes.toByteArray();
	}

}
