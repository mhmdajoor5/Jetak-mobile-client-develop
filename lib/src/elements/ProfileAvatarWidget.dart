import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';

class ProfileAvatarWidget extends StatelessWidget {
  final User user;

  ProfileAvatarWidget({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
      child: Column(
        children: <Widget>[
          Container(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(300)),
                  child: CachedNetworkImage(
                    height: 135,
                    width: 135,
                    fit: BoxFit.cover,
                    imageUrl: user.image?.url ?? '',
                    placeholder: (context, url) => Image.asset('assets/img/loading.gif', fit: BoxFit.cover, height: 135, width: 135),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ],
            ),
          ),
          Text(user.name ?? '', style: Theme.of(context).textTheme.headlineMedium?.merge(TextStyle(color: Theme.of(context).primaryColor))),
          Text(user.address ?? '', style: Theme.of(context).textTheme.bodySmall?.merge(TextStyle(color: Theme.of(context).primaryColor))),
        ],
      ),
    );
  }
}
