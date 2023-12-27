import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Our Privacy Policy',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'At DepthBlue, we are committed to ensuring the privacy and security of your personal information. This Privacy Policy outlines how we collect, use, and protect your data when you use our services. By using our services, you consent to the practices described in this policy.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                'Collection of Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'We utilize Firebase, a secure and trusted platform, to enhance the security of your information. Firebase employs advanced security measures to safeguard your data during transmission and storage. The information we collect may include, but is not limited to:'

                  'Personal Information: When you interact with our services, you may provide personal information such as your name, email address, or other details required for account registration.'

              'Usage Data: We may collect data on how you interact with our services, including device information, IP addresses, and usage patterns. This information helps us improve our services and provide you with a better user experience.'

              'Cookies: We may use cookies and similar technologies to collect information about your preferences and activities on our website. This helps us customize your experience and provide relevant content.'

                  'How We Use Your Information:'

                  'The information we collect is used for various purposes, including:'

              'Service Improvement: We analyze usage patterns to enhance our services, identify issues, and make improvements.'

              'Communication: We may use your contact information to send you important updates, announcements, or respond to your inquiries.'

              'Personalization: Your data may be used to personalize your experience, providing you with content and features tailored to your preferences.'

              'Security Measures:'

              'We prioritize the security of your information and have implemented industry-standard security measures, including encryption and access controls, to protect against unauthorized access, disclosure, or alteration of your data.'

              'Third-Party Services:'

              'Our services may include links to third-party websites or services. Please note that these third-party sites have their own privacy policies, and we are not responsible for their practices. We recommend reviewing the privacy policies of these third-party services.'

                  'Changes to Privacy Policy:'

                  'We reserve the right to update our Privacy Policy to reflect changes in our practices. We will notify you of any significant changes, and your continued use of our services after such changes will constitute your acceptance of the updated policy.'

              'Contact Us:'

                  'If you have any questions or concerns about our Privacy Policy, please contact us at contact@depthblue.com.'

              'This Privacy Policy was last updated on December 10, 2023.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
