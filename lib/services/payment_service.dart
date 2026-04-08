import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentService {
  static Future<void> makePayment(String amount) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'amount': amount, 'currency': 'USD'},
      );

      final paymentIntent = jsonDecode(response.body);

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Pet Food Shop',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      print("Payment Successful!");
    } catch (e) {
      print("Error: $e");
      rethrow;
    }
  }
}
