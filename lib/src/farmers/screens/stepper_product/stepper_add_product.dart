import 'package:flutter/material.dart';

class ProcessProduct extends StatelessWidget {
  const ProcessProduct({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Optional: centers the stepper
        child: SizedBox(
          width: MediaQuery.of(context).size.width, // or a fixed width
          child: Stepper(
            type: StepperType.horizontal,
            steps: [
              Step(title: Text("Product Details"), content: Container()),
              Step(title: Text("Delivery Options"), content: Container()),
              Step(title: Text("Confirmation"), content: Container()),
            ],
            // You might want to control currentStep and onStepTapped for interaction
            currentStep: 0,
            onStepTapped: (step) {
              // handle step tap if needed
            },
          ),
        ),
      ),
    );
  }
}
