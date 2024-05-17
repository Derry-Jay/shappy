import 'package:flutter/material.dart';
import 'package:shappy/src/models/faq.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shappy/src/controller/faq_controller.dart';
import 'package:shappy/src/elements/CircularLoadingWidget.dart';

class FrequentlyAskedQuestionsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FrequentlyAskedQuestionsPageState();
}

class FrequentlyAskedQuestionsPageState
    extends StateMVC<FrequentlyAskedQuestionsPage> {
  FrequentlyAskedQuestionsController _con;
  FrequentlyAskedQuestionsPageState()
      : super(FrequentlyAskedQuestionsController()) {
    _con = controller;
  }
  void initState() {
    _con.waitForFaq(faqType: 1);
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            title: Text("Faq & Support"),
            backgroundColor: Color(0xffe62136),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            )),
        body: Column(
          children: <Widget>[
            Container(
                height: MediaQuery.of(context).size.height / 40,
                decoration: BoxDecoration(
                    color: Color(0xffe62136),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20)))),
            Expanded(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: InkWell(
                              child: Card(
                                  elevation: 0,
                                  child: Container(
                                      child: Column(
                                        children: [
                                          Icon(Icons.wifi_calling_outlined,
                                              size: 35),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                200,
                                          ),
                                          Text("1234567890",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18))
                                        ],
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          vertical: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              50,
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              20))),
                              onTap: () => launch("tel://7338965667")),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 60,
                        ),
                        Expanded(
                            flex: 2,
                            child: InkWell(
                                child: Card(
                                  elevation: 0,
                                  child: Container(
                                      child: Column(
                                        children: [
                                          Icon(Icons.mail_outline_rounded,
                                              size: 35),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                100,
                                          ),
                                          Text("mail@mail.com",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18))
                                        ],
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          vertical: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              55,
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              60)),
                                ),
                                onTap: () => launch(
                                    "https://mail.google.com/mail/u/0/?pli=1#inbox?compose=new")))
                      ],
                    ),
                  ),
                  _con.faqs == null || _con.faqs.length == 0
                      ? CircularLoadingWidget(
                          height: 50,
                        )
                      : buildList(_con.faqs)
                ],
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 30,
                  vertical: MediaQuery.of(context).size.height / 40),
            ))
          ],
        ),
        backgroundColor: Color(0xfff3f2f2));
  }

  Widget buildList(List<FrequentlyAskedQuestion> faqs) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: faqs.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              width: double.infinity,
              // height: 80,
              // padding: EdgeInsets.only(left: 10.0,right: 10),
              child: Card(
                elevation: 0,
                child: ExpansionTile(
                    title: Text(faqs[index].question,
                        style: TextStyle(color: Colors.black, fontSize: 19)),
                    children: [
                      Container(
                          child: Text(faqs[index].answer,
                              textAlign: TextAlign.left,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 17)),
                          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height / 100))
                    ]),
              ));
        });
  }
}
