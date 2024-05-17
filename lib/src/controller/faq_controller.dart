import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/generated/l10n.dart';
import 'package:shappy/src/models/faq.dart';
import 'package:shappy/src/repository/faq_repository.dart' as repos;
class FrequentlyAskedQuestionsController extends ControllerMVC{
  List<FrequentlyAskedQuestion> faqs;
  GlobalKey<ScaffoldState> scaffoldKey;
  FrequentlyAskedQuestionsController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }
  void waitForFaq({int faqType}) async {
    await repos.getFAQ(faqType).then((value) {
      if(value!=null && value.length!=0){
        setState(() => faqs = value);
      } else {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).verify_your_internet_connection),
        ));
      }
    }).catchError((e){
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    });
  }
}