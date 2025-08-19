import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

void showPrivacyPolicyDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: SizedBox(
          width: 600,
          child: Text('Privacy Policy'),
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
                      'This page informs you of our policies regarding the collection, use, and disclosure of personal data when you use our Swift Contest application (the "Service") and the choices you have associated with that data.\n\n'
                      'We use your data to provide and improve the Service. By using the Service, you agree to the collection and use of information in accordance with this policy.\n\n',
                ),
                TextSpan(
                  text: '1. Information Collection and Use\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'We collect several different types of information for various purposes to provide and improve our Service to you.\n\n'
                      'Types of Data Collected:\n'
                      '• Personal Data: While using our Service, we may ask you to provide us with certain personally identifiable information that can be used to contact or identify you ("Personal Data"). This may include, but is not limited to: email address, full name.\n'
                      '• Usage Data: We may also collect information on how the Service is accessed and used ("Usage Data"). This Usage Data may include information such as your device\'s Internet Protocol address (e.g. IP address), the pages of our Service that you visit, the time and date of your visit, the time spent on those pages, and other diagnostic data.\n\n',
                ),
                TextSpan(
                  text: '2. Use of Data\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: 'Swift Contest uses the collected data for various purposes:\n'
                      '• To provide and maintain the Service\n'
                      '• To notify you about changes to our Service\n'
                      '• To allow you to participate in interactive features of our Service when you choose to do so\n'
                      '• To provide customer care and support\n'
                      '• To monitor the usage of the Service\n'
                      '• To detect, prevent and address technical issues\n\n',
                ),
                TextSpan(
                  text: '3. Service Providers\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'We may employ third-party companies and individuals to facilitate our Service ("Service Providers"), to provide the Service on our behalf, or to assist us in analyzing how our Service is used. These third parties have access to your Personal Data only to perform these tasks on our behalf and are obligated not to disclose or use it for any other purpose.\n\n',
                ),
                TextSpan(
                  text: '4. Data Security\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'The security of your data is important to us, but remember that no method of transmission over the Internet, or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your Personal Data, we cannot guarantee its absolute security.\n\n',
                ),
                TextSpan(
                  text: '5. Changes to This Privacy Policy\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page. You are advised to review this Privacy Policy periodically for any changes.\n\n',
                ),
                TextSpan(
                  text: '6. Contact Us\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: 'If you have any questions about this Privacy Policy, please contact us.',
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
