import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/chat.dart';
import '../repository/user_repository.dart';

class ChatMessageListItem extends StatelessWidget {
  final Chat chat;

  ChatMessageListItem({required this.chat});

  @override
  Widget build(BuildContext context) {
    return currentUser.value.id == this.chat.userId ? getSentMessageLayout(context) : getReceivedMessageLayout(context);
  }

  Widget getSentMessageLayout(context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).focusColor.withOpacity(0.2),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
        ),
        padding: EdgeInsets.symmetric(vertical: 7, horizontal: 15),
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(this.chat.user?.name ?? '', style: Theme.of(context).textTheme.bodyLarge?.merge(TextStyle(fontWeight: FontWeight.w600))),
                  Container(margin: const EdgeInsets.only(top: 5.0), child: Text(chat.text ?? '')),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 8.0),
              width: 42,
              height: 42,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(42)),
                child: CachedNetworkImage(
                  width: double.infinity,
                  fit: BoxFit.cover,
                  imageUrl: this.chat.user?.image?.thumb ?? '',
                  placeholder: (context, url) => Image.asset('assets/img/loading.gif', fit: BoxFit.cover, width: double.infinity),
                  errorWidget: (context, url, error) => Image.asset('assets/img/logo.png', fit: BoxFit.fill, ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getReceivedMessageLayout(context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
        ),
        padding: EdgeInsets.symmetric(vertical: 7, horizontal: 10),
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(right: 10),
              width: 42,
              height: 42,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(42)),
                child: CachedNetworkImage(
                  width: double.infinity,
                  fit: BoxFit.cover,
                  imageUrl: this.chat.user?.image?.thumb ?? '',
                  placeholder: (context, url) => Image.asset('assets/img/loading.gif', fit: BoxFit.cover, width: double.infinity),
                  errorWidget: (context, url, error) => Image.asset('assets/img/logo.png', fit: BoxFit.fill, ),
                ),
              ),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(this.chat.user?.name ?? '', style: Theme.of(context).textTheme.bodyLarge?.merge(TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor))),
                  Container(margin: const EdgeInsets.only(top: 5.0), child: Text(chat.text ?? '', style: TextStyle(color: Theme.of(context).primaryColor))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
