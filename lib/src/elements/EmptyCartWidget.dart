import 'dart:async';

import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../helpers/app_config.dart' as config;

class EmptyCartWidget extends StatefulWidget {
  const EmptyCartWidget({Key? key}) : super(key: key);

  @override
  _EmptyCartWidgetState createState() => _EmptyCartWidgetState();
}

class _EmptyCartWidgetState extends State<EmptyCartWidget> {
  bool loading = true;

  @override
  void initState() {
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (loading) SizedBox(height: 3, child: LinearProgressIndicator(backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2))),
        Container(
          alignment: AlignmentDirectional.center,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          height: config.App(context).appHeight(70),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [Theme.of(context).focusColor.withOpacity(0.7), Theme.of(context).focusColor.withOpacity(0.05)],
                      ),
                    ),
                    child: Icon(Icons.shopping_cart, color: Theme.of(context).scaffoldBackgroundColor, size: 70),
                  ),
                  Positioned(
                    right: -30,
                    bottom: -50,
                    child: Container(width: 100, height: 100, decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.15), borderRadius: BorderRadius.circular(150))),
                  ),
                  Positioned(
                    left: -20,
                    top: -50,
                    child: Container(width: 120, height: 120, decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.15), borderRadius: BorderRadius.circular(150))),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Opacity(
                opacity: 0.4,
                child: Text(
                  S.of(context).dont_have_any_item_in_your_cart,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.merge(const TextStyle(fontWeight: FontWeight.w300)),
                ),
              ),
              const SizedBox(height: 50),
              if (!loading)
                MaterialButton(
                  elevation: 0,
                  focusElevation: 0,
                  highlightElevation: 0,
                  onPressed: () {
                    Navigator.of(context).pushNamed('/Pages', arguments: 2);
                  },
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  color: Theme.of(context).colorScheme.secondary.withOpacity(1),
                  shape: const StadiumBorder(),
                  child: Text(S.of(context).start_exploring, style: Theme.of(context).textTheme.headlineSmall?.merge(TextStyle(color: Theme.of(context).scaffoldBackgroundColor))),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
