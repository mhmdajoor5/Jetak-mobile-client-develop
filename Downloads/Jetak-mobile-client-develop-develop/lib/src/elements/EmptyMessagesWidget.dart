import 'dart:async';
import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import '../helpers/app_config.dart' as config;

class EmptyMessagesWidget extends StatefulWidget {
  const EmptyMessagesWidget({Key? key}) : super(key: key);

  @override
  _EmptyMessagesWidgetState createState() => _EmptyMessagesWidgetState();
}

class _EmptyMessagesWidgetState extends State<EmptyMessagesWidget> {
  bool loading = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (loading) SizedBox(height: 3, child: LinearProgressIndicator(backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2))),
        Container(
          alignment: AlignmentDirectional.center,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          height: config.App(context).appHeight(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Opacity(
                opacity: 0.4,
                child: Text(
                  S.of(context).youDontHaveAnyConversations,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.merge(const TextStyle(fontWeight: FontWeight.w300)),
                ),
              ),
              const SizedBox(height: 20),
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
