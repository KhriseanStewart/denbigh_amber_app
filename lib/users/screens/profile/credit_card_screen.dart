import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  @override
  Widget build(BuildContext context) {
    //there is no card information available yet, so we will show a placeholder

    return Scaffold(
      appBar: AppBar(
        title: Text('Card Information'),
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CreditCardWidget(
              cardNumber: '',
              expiryDate: 'expiryDate',
              cardHolderName: 'cardHolderName',
              cvvCode: 'cvvCode',
              showBackView: false,
              enableFloatingCard: true,
              floatingConfig: FloatingConfig(
                isGlareEnabled: true,
                isShadowEnabled: true,
                shadowConfig: FloatingShadowConfig(
                  offset: Offset(0, 1),
                  color: Colors.black,
                  blurRadius: 4,
                ),
              ),
              onCreditCardWidgetChange: (p0) {},
            ),
            // CreditCardForm(
            //   formKey: formKey, // Required
            //   cardNumber: cardNumber, // Required
            //   expiryDate: expiryDate, // Required
            //   cardHolderName: cardHolderName, // Required
            //   cvvCode: cvvCode, // Required
            //   cardNumberKey: cardNumberKey,
            //   cvvCodeKey: cvvCodeKey,
            //   expiryDateKey: expiryDateKey,
            //   cardHolderKey: cardHolderKey,
            //   onCreditCardModelChange: (CreditCardModel data) {}, // Required
            //   obscureCvv: true,
            //   obscureNumber: true,
            //   isHolderNameVisible: true,
            //   isCardNumberVisible: true,
            //   isExpiryDateVisible: true,
            //   enableCvv: true,
            //   cvvValidationMessage: 'Please input a valid CVV',
            //   dateValidationMessage: 'Please input a valid date',
            //   numberValidationMessage: 'Please input a valid number',
            //   cardNumberValidator: (String? cardNumber) {},
            //   expiryDateValidator: (String? expiryDate) {},
            //   cvvValidator: (String? cvv) {},
            //   cardHolderValidator: (String? cardHolderName) {},
            //   isCardHolderNameUpperCase: true,
            //   onFormComplete: () {
            //     // callback to execute at the end of filling card data
            //   },
            //   autovalidateMode: AutovalidateMode.always,
            //   disableCardNumberAutoFillHints: false,
            //   inputConfiguration: const InputConfiguration(
            //     cardNumberDecoration: InputDecoration(
            //       border: OutlineInputBorder(),
            //       labelText: 'Number',
            //       hintText: 'XXXX XXXX XXXX XXXX',
            //     ),
            //     expiryDateDecoration: InputDecoration(
            //       border: OutlineInputBorder(),
            //       labelText: 'Expired Date',
            //       hintText: 'XX/XX',
            //     ),
            //     cvvCodeDecoration: InputDecoration(
            //       border: OutlineInputBorder(),
            //       labelText: 'CVV',
            //       hintText: 'XXX',
            //     ),
            //     cardHolderDecoration: InputDecoration(
            //       border: OutlineInputBorder(),
            //       labelText: 'Card Holder',
            //     ),
            //     cardNumberTextStyle: TextStyle(
            //       fontSize: 10,
            //       color: Colors.black,
            //     ),
            //     cardHolderTextStyle: TextStyle(
            //       fontSize: 10,
            //       color: Colors.black,
            //     ),
            //     expiryDateTextStyle: TextStyle(
            //       fontSize: 10,
            //       color: Colors.black,
            //     ),
            //     cvvCodeTextStyle: TextStyle(fontSize: 10, color: Colors.black),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
