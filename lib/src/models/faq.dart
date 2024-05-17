class FrequentlyAskedQuestion {
  final int faqID, faqType;
  final String question, answer;
  FrequentlyAskedQuestion(
      this.faqID, this.faqType, this.question, this.answer);
  factory FrequentlyAskedQuestion.fromMap(Map<String, dynamic> json) {
    return FrequentlyAskedQuestion(
        json['FAQ_ID'], json['Faq_type'], json['Faq_Qus'], json['Faq_Ans']);
  }
}
