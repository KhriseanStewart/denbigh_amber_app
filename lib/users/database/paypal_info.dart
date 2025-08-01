import 'dart:convert';

import 'package:http/http.dart' as http;

const apiKey =
    'Ac5RspmRa42iHqQAjHc-2DENbsqgPZiAuKLvrpFGIeyPahozD_Gwd3GMdCoVNnlsI4P7yqZVj-XyCW0V';
const userName = 'sb-cv78g44948678@business.example.com';
const key =
    'EEp3MPfQFIu9TbcK8UREZgc0ULPnWpH-SWeDF-dtM4RxcBY3v7vl5AtwqsFZv65Dou0u8CIGsoywxMXC';
const clientId =
    'AbjCdJBRfitg8zKU29ulX6fu7k4fgdAzGczbdzfqsbAd2pU7j37QyObkXVRkH5e2M5Ijzp0aa4zNNCI7';
const secret =
    'EKwmuif3IiPToS_EZaC_YR8KlGB6VdgfghX0GpwMGwDGCOfXFhDg472rD8KLh-rdtoL2vmf5jxheAMf_';

class PaypalInfo {
  Future<String?> getPaypalAccessToken() async {
    final url = Uri.parse('https://api.sandbox.paypal.com/v1/oauth2/token');

    final response = await http.post(
      url,
      headers: {
        'Authorization':
            'Basic ' + base64Encode(utf8.encode('$clientId:$secret')),
        'Accept': 'application/json',
        'Accept-Language': 'en_US',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
      encoding: Encoding.getByName('utf-8'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    } else {
      return null;
    }
  }

  Future<bool> createCreditCardPayment(
    double amount,
    String description,
    String accessToken,
  ) async {
    final url = Uri.parse('https://api.sandbox.paypal.com/v1/payments/payment');

    final body = {
      'intent': 'sale',
      'payer': {
        'payment_method': 'credit_card',
        'funding_instruments': [
          {
            'credit_card': {
              'number': '4032037954564403',
              'type': 'visa',
              'expire_month': 1,
              'expire_year': 2025,
              'cvv2': '123',
              'first_name': 'tester',
              'last_name': 'user',
              'billing_address': {
                'line1': '123 Main St',
                'city': 'San Jose',
                'state': 'CA',
                'postal_code': '95131',
                'country_code': 'US',
              },
            },
          },
        ],
      },
      'transactions': [
        {
          'amount': {'total': amount.toStringAsFixed(2), 'currency': 'USD'},
          'description': description,
        },
      ],
      'redirect_urls': {
        'return_url': 'https://your-return-url.com',
        'cancel_url': 'https://your-cancel-url.com',
      },
      'payee': {'email': 'sb-5biut44948685@business.example.com'},
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);

      return true;
    } else {
      return false;
    }
  }

  Future<bool?> createPaypalPayment(
    double amount,
    String description,
    String accessToken,
  ) async {
    final url = Uri.parse('https://api.sandbox.paypal.com/v1/payments/payment');

    final body = {
      'intent': 'sale',
      'payer': {'payment_method': 'paypal'},
      'transactions': [
        {
          'amount': {'total': amount.toStringAsFixed(2), 'currency': 'USD'},
          'description': description,
        },
      ],
      'redirect_urls': {
        'return_url': 'https://your-return-url.com',
        'cancel_url': 'https://your-cancel-url.com',
      },
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);

      return true;
    } else {
      return false;
    }
  }

  // String _paymentResult = '';
  // String tokenizationKey = 'sandbox_zdhhvxgd_shxt8sxrs7x7nzzs';

  // payment() async {
  //   var request = BraintreeDropInRequest(
  //     paypalEnabled: false,
  //     clientToken: '<Insert your client token here>',
  //     collectDeviceData: true,
  //     requestThreeDSecureVerification: true,
  //     email: "test@email.com",
  //     amount: "0,01",
  //     billingAddress: BraintreeBillingAddress(
  //       givenName: "Jill",
  //       surname: "Doe",
  //       phoneNumber: "5551234567",
  //       streetAddress: "555 Smith St",
  //       extendedAddress: "#2",
  //       locality: "Chicago",
  //       region: "IL",
  //       postalCode: "12345",
  //       countryCodeAlpha2: "US",
  //     ),
  //     cardEnabled: true,
  //   );
  //   try {
  //     final result = await BraintreeDropIn.start(request);
  //     if (result != null) {
  //       _paymentResult =
  //           'Payment nonce: ${result.paymentMethodNonce.description}';
  //       return _paymentResult;
  //     } else {
  //       _paymentResult = 'Payment canceled.';
  //       return _paymentResult;
  //     }
  //   } catch (e) {
  //     _paymentResult = 'Error: $e';
  //   }
  // }
}
