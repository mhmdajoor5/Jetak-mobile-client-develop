import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../helpers/helper.dart';
import '../models/review.dart';

// ignore: must_be_immutable
class ReviewItemWidget extends StatelessWidget {
  Review review;

  ReviewItemWidget({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Wrap(
        direction: Axis.horizontal,
        runSpacing: 10,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                child: CachedNetworkImage(
                  height: 65,
                  width: 65,
                  fit: BoxFit.cover,
                  imageUrl: review.user.image?.thumb ?? '',
                  placeholder: (context, url) => Image.asset('assets/img/loading.gif', fit: BoxFit.cover, height: 65, width: 65),
                  errorWidget: (context, url, error) => Image.asset('assets/img/logo.png', fit: BoxFit.fill, ),
                ),
              ),
              SizedBox(width: 15),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            review.user.name ?? '',
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.headlineSmall?.merge(TextStyle(color: Theme.of(context).hintColor)),
                          ),
                        ),
                        SizedBox(
                          height: 32,
                          child: Chip(
                            padding: EdgeInsets.all(0),
                            label: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(review.rate.toString(), style: Theme.of(context).textTheme.bodyLarge?.merge(TextStyle(color: Theme.of(context).primaryColor))),
                                Icon(Icons.star_border, color: Theme.of(context).primaryColor, size: 16),
                              ],
                            ),
                            backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                            shape: StadiumBorder(),
                          ),
                        ),
                      ],
                    ),
                    Text(review.user.bio!.substring(0, min(30, review.user.bio?.length ?? 0)), overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          Text(Helper.skipHtml(review.review), style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis, softWrap: false, maxLines: 3),
        ],
      ),
    );
  }
}
