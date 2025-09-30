import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cinematic_mobile/providers/base_provider.dart';

class UplataProvider extends BaseProvider {
  UplataProvider() : super("Uplate");

  Future<Map<String, dynamic>> createPaymentIntent(int amountInCents) async {
  var url = "$baseUrl$endpoint/create-payment-intent";
  var uri = Uri.parse(url);

  var headers = createHeaders();

  var response = await http.post(
    uri,
    headers: headers,
    body: jsonEncode({'iznos': amountInCents}),
  );

  print('Stripe response: ${response.body}');

  if (isValidResponse(response)) {
    try {
      final decoded = jsonDecode(response.body);
      print('Decoded: $decoded');
      return decoded;
    } catch (e) {
      print('JSON decode error: $e');
      throw Exception('JSON decode error: $e\nOdgovor: ${response.body}');
    }
  } else {
    throw Exception('Failed to create payment intent: ${response.body}');
  }
}

 Future<String> checkPaymentStatus(String paymentIntentId) async {
    var url = "$baseUrl$endpoint/status/$paymentIntentId";
    var uri = Uri.parse(url);

    var headers = createHeaders();

    var response = await http.post(
      uri,
      headers: headers,
    );

    print('Stripe status response: ${response.body}');

    if (isValidResponse(response)) {
      try {
        final decoded = jsonDecode(response.body);
        print('Decoded status: $decoded');
        return decoded['status'] ?? 'unknown';
      } catch (e) {
        print('JSON decode error: $e');
        throw Exception('JSON decode error: $e\nOdgovor: ${response.body}');
      }
    } else {
      throw Exception('Failed to check payment status: ${response.body}');
    }
  }
}