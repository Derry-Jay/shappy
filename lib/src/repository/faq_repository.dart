import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shappy/src/models/faq.dart';
import 'package:shappy/src/models/faq_base.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:global_configuration/global_configuration.dart';

Future<SharedPreferences> _sharePrefs = SharedPreferences.getInstance();

Future<List<FrequentlyAskedQuestion>> getFAQ(int faqType) async {
  final client = new http.Client();
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url = GlobalConfiguration().getString('api_base_url') +
      (faqType == 1 ? 'userFAQ' : 'shopFAQ');
  try {
    final response = await client.post(url, headers: {
      HttpHeaders.authorizationHeader:
          "Bearer " + sharedPrefs.getString("apiToken")
    }, body: {
      "Faq_type": faqType.toString()
    });
    print(response.statusCode);
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonString =
          json.decode(response.body) as Map<String, dynamic>;
      return FrequentlyAskedQuestionsBase.fromMap(jsonString).faqs;
    } else {
      throw Exception("Unable to get FAQ from the REST API");
    }
  } catch (e) {
    print(e);
    throw (e);
  }
}
