import 'package:flutter/material.dart';
import '../helpers/helper.dart';
import '../models/faq.dart';

class FaqItemWidget extends StatelessWidget {
  final Faq faq;

  const FaqItemWidget({Key? key, required this.faq}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), offset: Offset(0, 5), blurRadius: 15)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(color: Theme.of(context).focusColor, borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5))),
            child: Text(Helper.skipHtml(faq.question), style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).primaryColor)),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.only(bottomRight: Radius.circular(5), bottomLeft: Radius.circular(5))),
            child: Text(Helper.skipHtml(faq.answer), style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
