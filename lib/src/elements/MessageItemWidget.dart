import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../generated/l10n.dart';
import '../models/conversation.dart' as model;
import '../models/route_argument.dart';
import '../repository/user_repository.dart';

class MessageItemWidget extends StatefulWidget {
  final model.Conversation message;
  final ValueChanged<model.Conversation> onDismissed;

  MessageItemWidget({Key? key, required this.message, required this.onDismissed}) : super(key: key);

  @override
  _MessageItemWidgetState createState() => _MessageItemWidgetState();
}

class _MessageItemWidgetState extends State<MessageItemWidget> {
  @override
  Widget build(BuildContext context) {
    final otherUser = widget.message.users.firstWhere((element) => element.id != currentUser.value.id, orElse: () => widget.message.users.first);

    return Dismissible(
      key: Key(widget.message.hashCode.toString()),
      background: Container(
        color: Colors.red,
        child: Align(alignment: Alignment.centerRight, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Icon(Icons.delete, color: Colors.white))),
      ),
      onDismissed: (direction) {
        setState(() {
          widget.onDismissed(widget.message);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("The conversation with ${widget.message.name} is dismissed"), duration: Duration(milliseconds: 300)));
      },
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed('/Chat', arguments: RouteArgument(param: widget.message));
        },
        child: Container(
          color: widget.message.readByUsers.contains(currentUser.value.id) ? Colors.transparent : Theme.of(context).focusColor.withOpacity(0.05),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(60)),
                      child: CachedNetworkImage(
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        imageUrl: otherUser.image?.thumb ?? '',
                        placeholder: (context, url) => Image.asset('assets/img/loading.gif', fit: BoxFit.cover, width: double.infinity, height: 140),
                        errorWidget: (context, url, error) => Image.asset('assets/img/logo.png', fit: BoxFit.fill, ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 3,
                    right: 3,
                    width: 12,
                    height: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // color: determine user status color if needed
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 15),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.message.name,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: Theme.of(context).textTheme.bodyLarge!.merge(TextStyle(fontWeight: widget.message.readByUsers.contains(currentUser.value.id) ? FontWeight.w400 : FontWeight.w800)),
                          ),
                        ),
                        Text(
                          DateFormat(S.of(context).HHmm).format(DateTime.fromMillisecondsSinceEpoch(widget.message.lastMessageTime, isUtc: true)),
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            widget.message.lastMessage,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.bodySmall!.merge(TextStyle(fontWeight: widget.message.readByUsers.contains(currentUser.value.id) ? FontWeight.w400 : FontWeight.w800)),
                          ),
                        ),
                        Text(
                          DateFormat(S.of(context).ddMMyyyy).format(DateTime.fromMillisecondsSinceEpoch(widget.message.lastMessageTime, isUtc: true)),
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
