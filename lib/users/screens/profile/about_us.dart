import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with title
      appBar: AppBar(title: Text('About Us'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main Title
              Text(
                'Meet Our Dynamic Team',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              // Team Description
              Text(
                'We are a passionate group of mobile developers dedicated to creating innovative and user-friendly applications. Our team worked tirelessly over a three-week sprint to design, develop, and integrate multiple features, bringing this app to its Minimum Viable Product (MVP) stage.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              // Team Members
              TeamMemberCard(
                name: 'Khrisean Stewart',
                role: 'Project Leader',
                description:
                    'Guiding the project with strategic vision, Khrisean led the team through planning, coordination, and execution, ensuring timely delivery of key features.',
              ),
              SizedBox(height: 20),
              TeamMemberCard(
                name: 'Kashime Anderson',
                role: 'Designer & Programmer',
                description:
                    'Designing intuitive user interfaces and coding core functionalities, Kashime brought creativity and technical expertise to the project.',
              ),
              SizedBox(height: 20),
              TeamMemberCard(
                name: 'Dovado & Livingston',
                role: 'Backend & Frontend Programmers',
                description:
                    'Dovado and Livingston worked collaboratively to develop robust backend systems and seamless frontend experiences, ensuring the app’s performance and reliability.',
              ),
              SizedBox(height: 30),
              // Additional Info
              Text(
                'Our Commitment:\n\nWe took on this project with a clear goal: to rapidly develop a high-quality MVP that meets everyones\' needs. Despite the tight three-week deadline, our team demonstrated exceptional collaboration, technical skill, and dedication to deliver an app that is scalable and ready for future enhancements.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 20),
              // Call to Action or closing statement
              Text(
                'Thank you for taking the time to learn about us. We are excited about the future and look forward to building more innovative solutions together!',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TeamMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final String description;

  const TeamMemberCard({
    Key? key,
    required this.name,
    required this.role,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 4),
            Text(
              role,
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
