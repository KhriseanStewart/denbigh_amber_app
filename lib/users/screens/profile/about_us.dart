import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with title
      appBar: AppBar(title: Text('About Us'), centerTitle: true),
      body: SingleChildScrollView(
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
                color: Colors.greenAccent,
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
            TeamCard(
              name: 'Khrisean Stewart',
              role: 'Project Leader',
              email: 'khrisean.stewart@gmail.com',
              description:
                  'Guiding the project with strategic vision, Khrisean led the team through planning, coordination, and execution, ensuring timely delivery of key features.',
            ),
            SizedBox(height: 20),
            TeamCard(
              name: 'Kashime Anderson',
              role: 'Designer & Programmer',
              email: 'kashime.anderson@gmail.com',
              description:
                  'Designing intuitive user interfaces and coding core functionalities, Kashime brought creativity and technical expertise to the project.',
            ),
            SizedBox(height: 20),
            TeamCard(
              name: 'Dovado Evans & Livingston Mitchell',
              role: 'Backend & Frontend Programmers',
              email: 'dovado@gmail.com\nlivingston@gmail.com',
              description:
                  'Dovado and Livingston worked collaboratively to develop robust backend systems and seamless frontend experiences, ensuring the app\'s performance and reliability.',
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
                color: Colors.greenAccent,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class TeamCard extends StatefulWidget {
  final String name;
  final String role;
  final String email;
  final String description;

  const TeamCard({
    Key? key,
    required this.name,
    required this.role,
    required this.email,
    required this.description,
  }) : super(key: key);

  @override
  _TeamCardState createState() => _TeamCardState();
}

class _TeamCardState extends State<TeamCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isFlipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (!isFlipped) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    isFlipped = !isFlipped;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final isShowingFront = _animation.value < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_animation.value * 3.14159),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                height: 200,
                padding: EdgeInsets.all(16),
                child: isShowingFront ? _buildFrontCard() : _buildBackCard(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFrontCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),
            ),
            
          ],
        ),
        SizedBox(height: 4),
        Text(
          widget.role,
          style: TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 10),
        Expanded(
          child: Text(
            widget.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.4,
            ),
            overflow: TextOverflow.visible,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Tap to see contact info',
          style: TextStyle(
            fontSize: 12,
            color: Colors.greenAccent,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildBackCard() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.14159),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.greenAccent,
                size: 24,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Icon(
                Icons.work,
                color: Colors.grey[600],
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.role,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Icon(
                Icons.email,
                color: Colors.grey[600],
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.email,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
         
        ],
      ),
    );
  }
}
