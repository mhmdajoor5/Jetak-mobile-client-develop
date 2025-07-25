import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../generated/l10n.dart';
import '../controllers/razorpay_controller.dart';
import '../models/route_argument.dart';

// ignore: must_be_immutable
class RazorPayPaymentWidget extends StatefulWidget {
  RouteArgument? routeArgument;

  RazorPayPaymentWidget({Key? key, this.routeArgument}) : super(key: key);

  @override
  _RazorPayPaymentWidgetState createState() => _RazorPayPaymentWidgetState();
}

class _RazorPayPaymentWidgetState extends StateMVC<RazorPayPaymentWidget> {
  late RazorPayController _con;

  _RazorPayPaymentWidgetState() : super(RazorPayController()) {
    _con = controller as RazorPayController;
  }

  late WebViewController webViewController;
  @override
  void initState() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(

          onPageStarted: (String url) {
            setState(() {
              _con.url = url;
            });
            if (url == "${GlobalConfiguration().getValue('base_url')}payments/razorpay") {
              Navigator.of(context).pushReplacementNamed('/Pages', arguments: 3);
            }
          },
          onPageFinished: (String url) {
            setState(() {
              _con.progress = 1;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_con.url));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).razorpayPayment,
          style: Theme.of(context).textTheme.headlineSmall?.merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      body: Stack(
        children: <Widget>[
          WebViewWidget(
            controller: webViewController,
              // onWebViewCreated: (WebViewController controller) {
              //   _con.webView = controller;
              // },
          ),
          _con.progress < 1
              ? SizedBox(
                  height: 3,
                  child: LinearProgressIndicator(
                    backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
