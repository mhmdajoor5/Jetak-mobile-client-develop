import 'package:flutter/material.dart';

import '../models/food.dart';
import '../models/route_argument.dart';

class FoodGridItemWidget extends StatefulWidget {
  final String heroTag;
  final Food food;
  final VoidCallback onPressed;

  FoodGridItemWidget({Key? key, required this.heroTag, required this.food, required this.onPressed}) : super(key: key);

  @override
  _FoodGridItemWidgetState createState() => _FoodGridItemWidgetState();
}

class _FoodGridItemWidgetState extends State<FoodGridItemWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Theme.of(context).colorScheme.secondary.withOpacity(0.08),
      onTap: () {
        Navigator.of(context).pushNamed('/Food', arguments: RouteArgument(heroTag: widget.heroTag, id: widget.food.id));
      },
      child: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Hero(
                  tag: widget.heroTag + widget.food.id,
                  child: Container(decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(widget.food.image?.thumb ?? ''), fit: BoxFit.cover), borderRadius: BorderRadius.circular(5))),
                ),
              ),
              SizedBox(height: 5),
              Text(widget.food.name, style: Theme.of(context).textTheme.bodyLarge, overflow: TextOverflow.ellipsis),
              SizedBox(height: 2),
              Text(widget.food.restaurant.name, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
            ],
          ),
          Container(
            margin: EdgeInsets.all(10),
            width: 40,
            height: 40,
            child: MaterialButton(
              elevation: 0,
              focusElevation: 0,
              highlightElevation: 0,
              padding: EdgeInsets.all(0),
              onPressed: widget.onPressed,
              child: Icon(Icons.shopping_cart, color: Theme.of(context).primaryColor, size: 24),
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.9),
              shape: StadiumBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
