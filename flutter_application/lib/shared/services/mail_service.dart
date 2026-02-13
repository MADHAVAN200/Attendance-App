import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class MailService {
  static final MailService _instance = MailService._internal();
  factory MailService() => _instance;
  MailService._internal();

  /// Constants from .env
  String get _emailUser => dotenv.env['EMAIL_USER'] ?? '';
  String get _emailPass => dotenv.env['EMAIL_PASS'] ?? '';
  String get _adminEmails => dotenv.env['ADMIN_EMAIL'] ?? '';

  /// Send Feedback Email
  Future<bool> sendFeedbackEmail({
    required String title,
    required String description,
    required String type,
    List<File>? attachments,
  }) async {
    if (_emailUser.isEmpty || _emailPass.isEmpty) {
      print('Cannot send email: Missing credentials in .env');
      return false;
    }

    // Configure SMTP server (Gmail)
    final smtpServer = gmail(_emailUser, _emailPass);

    // Create the message
    final message = Message()
      ..from = Address(_emailUser, 'Mano Attention App')
      ..subject = '[$type] $title';

    // Add Recipients
    // 1. Add Admins
    if (_adminEmails.isNotEmpty) {
      final admins = _adminEmails.split(',').map((e) => e.trim()).toList();
      for (var admin in admins) {
         if (admin.isNotEmpty) message.recipients.add(admin);
      }
    }
    // 2. Add Self (Sender) as backup/confirmation if list is empty, or just rely on admins
    if (message.recipients.isEmpty) {
      message.recipients.add(_emailUser);
    }

    message.text = 'Type: $type\n\nTitle: $title\n\nDescription:\n$description';
    message.html = '''
      <h3>New Feedback Received</h3>
      <p><strong>Type:</strong> $type</p>
      <p><strong>Title:</strong> $title</p>
      <p><strong>Description:</strong></p>
      <p>$description</p>
      <br>
      <p><small>Sent from Mano Attention App</small></p>
    ''';

    // Add attachments
    if (attachments != null) {
      for (var file in attachments) {
        message.attachments.add(FileAttachment(file));
      }
    }

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ${sendReport.toString()}');
      return true;
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      return false;
    } catch (e) {
      print('Error sending email: $e');
      return false;
    }
  }

  /// Send Password Reset OTP
  Future<bool> sendPasswordResetOtp({
    required String recipientEmail,
    required String otp,
  }) async {
    if (_emailUser.isEmpty || _emailPass.isEmpty) {
      print('Cannot send email: Missing credentials in .env');
      return false;
    }

    final smtpServer = gmail(_emailUser, _emailPass);

    final message = Message()
      ..from = Address(_emailUser, 'Mano Attention App')
      ..recipients.add(recipientEmail)
      ..subject = 'Password Reset OTP - Mano Attendance App'
      ..text = 'Your OTP for password reset is: $otp. Do not share this code.'
      ..html = '''
        <div style="font-family: Arial, sans-serif; padding: 20px;">
          <h2>Password Reset Request</h2>
          <p>You requested a password reset for your Mano Attendance App account.</p>
          <p>Your One-Time Password (OTP) is:</p>
          <h1 style="color: #4A90E2; letter-spacing: 5px;">$otp</h1>
          <p>If you did not request this, please ignore this email.</p>
        </div>
      ''';

    try {
      await send(message, smtpServer);
      return true;
    } catch (e) {
      print('Error sending OTP email: $e');
      return false;
    }
  }
}
