import 'package:denbigh_app/users/database/order_service.dart';
import 'package:denbigh_app/users/database/paypal_info.dart';
import 'package:denbigh_app/widgets/custom_btn.dart';
import 'package:denbigh_app/widgets/misc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final formKeyOne = GlobalKey<FormState>();
  final cvvKey = GlobalKey<FormFieldState<String>>();
  final expDate = GlobalKey<FormFieldState<String>>();
  final cardHolder = GlobalKey<FormFieldState<String>>();
  final cardNumberKey = GlobalKey<FormFieldState<String>>();
  bool _isProcessingOrder = false;
  double totalCost = 0;

  final userId = FirebaseAuth.instance.currentUser!.uid;

  /// Handle checkout process
  Future<void> _handleCheckout() async {
    if (_isProcessingOrder) return;

    setState(() {
      _isProcessingOrder = true;
    });
    final token = await PaypalInfo().getPaypalAccessToken();

    if (token != null) {
      final payment = await PaypalInfo().createPaypalPayment(
        totalCost,
        "AgriConnect Payment",
        token,
      );
      if (payment == true) {
        try {
          final success = await OrderService().createOrderFromCart(userId);

          if (success) {
            displaySnackBar(context, "Order placed successfully!");
            Future.microtask(() {
              Duration(seconds: 2);
              Navigator.pop(context);
            });
          } else {
            displaySnackBar(
              context,
              "Failed to place order. Please try again.",
            );
          }
        } catch (e) {
          displaySnackBar(context, "Error: ${e.toString()}");
        } finally {
          setState(() {
            _isProcessingOrder = false;
          });
        }
      } else {
        setState(() {
          _isProcessingOrder = false;
        });
        displaySnackBar(context, "Error: Payment Error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    totalCost = args['totalCost'];
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CreditCardWidget(
              cardBgColor: Colors.deepOrangeAccent,
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              showBackView: false,
              enableFloatingCard: true,
              floatingConfig: FloatingConfig(
                isGlareEnabled: true,
                isShadowEnabled: true,
              ),
              onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
            ),
            CreditCardForm(
              formKey: formKeyOne, // Required
              cardNumber: cardNumber, // Required
              expiryDate: expiryDate, // Required
              cardHolderName: cardHolderName, // Required
              cvvCode: cvvCode, // Required
              cardNumberKey: cardNumberKey,
              cvvCodeKey: cvvKey,
              expiryDateKey: expDate,
              cardHolderKey: cardHolder,
              onCreditCardModelChange: onCreditCardModelChange,
              obscureCvv: true,
              obscureNumber: true,
              isHolderNameVisible: true,
              isCardNumberVisible: true,
              isExpiryDateVisible: true,
              enableCvv: true,
              cvvValidationMessage: 'Please input a valid CVV',
              dateValidationMessage: 'Please input a valid date',
              numberValidationMessage: 'Please input a valid number',
              cardNumberValidator: (String? cardNumber) {
                return null;
              },
              expiryDateValidator: (String? expiryDate) {
                return null;
              },
              cvvValidator: (String? cvv) {
                return null;
              },
              cardHolderValidator: (String? cardHolderName) {
                return null;
              },
              isCardHolderNameUpperCase: true,
              onFormComplete: () {
                // callback to execute at the end of filling card data
              },
              autovalidateMode: AutovalidateMode.always,
              disableCardNumberAutoFillHints: false,
              inputConfiguration: const InputConfiguration(
                cardNumberDecoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Number',
                  hintText: 'XXXX XXXX XXXX XXXX',
                ),
                expiryDateDecoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Expired Date',
                  hintText: 'XX/XX',
                ),
                cvvCodeDecoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'CVV',
                  hintText: 'XXX',
                ),
                cardHolderDecoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Card Holder',
                ),
                cardNumberTextStyle: TextStyle(
                  fontSize: 10,
                  color: Colors.black,
                ),
                cardHolderTextStyle: TextStyle(
                  fontSize: 10,
                  color: Colors.black,
                ),
                expiryDateTextStyle: TextStyle(
                  fontSize: 10,
                  color: Colors.black,
                ),
                cvvCodeTextStyle: TextStyle(fontSize: 10, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: CustomButtonElevated(
                btntext: _isProcessingOrder ? "Validating" : "Paypal",
                icon: Icon(Icons.paypal_outlined, size: 28),
                onpress: _isProcessingOrder ? null : _handleCheckout,
                bgcolor: _isProcessingOrder ? Colors.grey : Colors.orangeAccent,
                textcolor: Colors.white,
                isBoldtext: true,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
