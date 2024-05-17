import 'faq.dart';

class FrequentlyAskedQuestionsBase {
  final bool success;
  final List<FrequentlyAskedQuestion> faqs;
  FrequentlyAskedQuestionsBase(this.success, this.faqs);
  factory FrequentlyAskedQuestionsBase.fromMap(Map<String, dynamic> json) {
    return FrequentlyAskedQuestionsBase(
        json['success'],
        json['FAQs'] != null
            ? List.from(json['FAQs'])
                .map((element) => FrequentlyAskedQuestion.fromMap(element))
                .toList()
            : <FrequentlyAskedQuestion>[]);
  }
}
