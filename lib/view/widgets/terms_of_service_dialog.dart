import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

void showTermsOfServiceDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: SizedBox(
          width: 600,
          child: Text('Terms of Service'),
        ),
        content: SingleChildScrollView(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: const [
                TextSpan(
                  text: 'Last updated: July 31, 2024\n\n',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                TextSpan(
                  text:
                      'Please read these Terms of Service ("Terms", "Terms of Service") carefully before using the Swift Contest mobile application (the "Service") operated by us.\n\n'
                      'Your access to and use of the Service is conditioned on your acceptance of and compliance with these Terms. These Terms apply to all visitors, users, and others who access or use the Service. By accessing or using the Service you agree to be bound by these Terms. If you disagree with any part of the terms then you may not access the Service.\n\n',
                ),
                TextSpan(
                  text: '1. Accounts\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'When you create an account with us, you must provide us information that is accurate, complete, and current at all times. Failure to do so constitutes a breach of the Terms, which may result in immediate termination of your account on our Service.\n'
                      'You are responsible for safeguarding the password that you use to access the Service and for any activities or actions under your password. You agree not to disclose your password to any third party. You must notify us immediately upon becoming aware of any breach of security or unauthorized use of your account.\n\n',
                ),
                TextSpan(
                  text: '2. Contests and User Content\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'Our Service allows you to create, participate in, and manage contests ("Contests"). You are responsible for the content that you post to the Service, including its legality, reliability, and appropriateness ("User Content").\n'
                      'By posting User Content on the Service, you grant us the right and license to use, modify, publicly perform, publicly display, reproduce, and distribute such User Content on and through the Service. You retain any and all of your rights to any User Content you submit, post or display on or through the Service and you are responsible for protecting those rights.\n\n',
                ),
                TextSpan(
                  text: '3. Prohibited Uses\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'You agree not to use the Service for any purpose that is illegal or prohibited by these Terms. You may not use the Service in any manner that could damage, disable, overburden, or impair the Service.\n\n',
                ),
                TextSpan(
                  text: '4. Termination\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'We may terminate or suspend your account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.\n\n',
                ),
                TextSpan(
                  text: '5. Changes\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. We will try to provide at least 30 days\' notice prior to any new terms taking effect. What constitutes a material change will be determined at our sole discretion.\n\n',
                ),
                TextSpan(
                  text: '6. Contact Us\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: 'If you have any questions about these Terms, please contact us.',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.router.pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}
