import 'package:flutter/material.dart';
import '../helpers/helper.dart';
import '../models/extra.dart';

class ExtraItemWidget extends StatefulWidget {
  final Extra extra;
  final VoidCallback onChanged;

  const ExtraItemWidget({Key? key, required this.extra, required this.onChanged}) : super(key: key);

  @override
  _ExtraItemWidgetState createState() => _ExtraItemWidgetState();
}

class _ExtraItemWidgetState extends State<ExtraItemWidget> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;
  late Animation<double> sizeCheckAnimation;
  late Animation<double> rotateCheckAnimation;
  late Animation<double> opacityAnimation;
  late Animation<double> opacityCheckAnimation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(duration: Duration(milliseconds: 350), vsync: this);
    final curve = CurvedAnimation(parent: animationController, curve: Curves.easeOut);
    animation = Tween<double>(begin: 0.0, end: 60.0).animate(curve)..addListener(() {
      setState(() {});
    });
    opacityAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(curve)..addListener(() {
      setState(() {});
    });
    opacityCheckAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curve)..addListener(() {
      setState(() {});
    });
    rotateCheckAnimation = Tween<double>(begin: 2.0, end: 0.0).animate(curve)..addListener(() {
      setState(() {});
    });
    sizeCheckAnimation = Tween<double>(begin: 0, end: 36).animate(curve)..addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.extra.checked) {
          animationController.reverse();
        } else {
          animationController.forward();
        }
        setState(() {
          widget.extra.checked = !widget.extra.checked;
        });
        widget.onChanged();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Checkbox(
            value: widget.extra.checked,
            onChanged: (bool? value) {
              if (value != null) {
                setState(() {
                  widget.extra.checked = value;
                });
                widget.onChanged();
              }
            },
          ),
          const SizedBox(width: 15),
          Flexible(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 12),
                      Text(widget.extra.name, overflow: TextOverflow.ellipsis, maxLines: 2, style: Theme.of(context).textTheme.titleMedium),
                      Text(Helper.skipHtml(widget.extra.description), overflow: TextOverflow.ellipsis, maxLines: 2, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Helper.getPrice(widget.extra.price, context, style: Theme.of(context).textTheme.headlineLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
