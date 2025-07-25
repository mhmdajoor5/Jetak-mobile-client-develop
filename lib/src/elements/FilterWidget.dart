import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/filter_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../models/filter.dart';

class FilterWidget extends StatefulWidget {
  final ValueChanged<Filter> onFilter;

  FilterWidget({Key? key, required this.onFilter}) : super(key: key);

  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends StateMVC<FilterWidget> {
  late FilterController _con;

  _FilterWidgetState() : super(FilterController()) {
    _con = controller as FilterController;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(S.of(context).filter),
                  MaterialButton(
                    onPressed: () {
                      _con.clearFilter();
                    },
                    child: Text(S.of(context).clear, style: Theme.of(context).textTheme.bodyLarge),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                primary: true,
                shrinkWrap: true,
                children: <Widget>[
                  ExpansionTile(
                    title: Text(S.of(context).delivery_or_pickup),
                    children: [
                      CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.trailing,
                        value: _con.filter.delivery,
                        onChanged: (value) {
                          setState(() {
                            _con.filter.delivery = true;
                          });
                        },
                        title: Text(S.of(context).delivery, overflow: TextOverflow.fade, softWrap: false, maxLines: 1),
                      ),
                      CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.trailing,
                        value: !_con.filter.delivery,
                        onChanged: (value) {
                          setState(() {
                            _con.filter.delivery = false;
                          });
                        },
                        title: Text(S.of(context).pickup, overflow: TextOverflow.fade, softWrap: false, maxLines: 1),
                      ),
                    ],
                    initiallyExpanded: true,
                  ),
                  ExpansionTile(
                    title: Text(S.of(context).opened_restaurants),
                    children: [
                      CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.trailing,
                        value: _con.filter.open,
                        onChanged: (value) {
                          setState(() {
                            _con.filter.open = value ?? false;
                          });
                        },
                        title: Text(S.of(context).open, overflow: TextOverflow.fade, softWrap: false, maxLines: 1),
                      ),
                    ],
                    initiallyExpanded: true,
                  ),
                  _con.cuisines.isEmpty
                      ? CircularLoadingWidget(height: 100)
                      : ExpansionTile(
                        title: Text(S.of(context).cuisines),
                        children: List.generate(_con.cuisines.length, (index) {
                          return CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.trailing,
                            value: _con.cuisines[index].selected,
                            onChanged: (value) {
                              _con.onChangeCuisinesFilter(index);
                            },
                            title: Text(_con.cuisines[index].name, overflow: TextOverflow.fade, softWrap: false, maxLines: 1),
                          );
                        }),
                        initiallyExpanded: true,
                      ),
                ],
              ),
            ),
            SizedBox(height: 15),
            MaterialButton(
              elevation: 0,
              focusElevation: 0,
              highlightElevation: 0,
              onPressed: () {
                _con.saveFilter().whenComplete(() {
                  widget.onFilter(_con.filter);
                });
              },
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              color: Theme.of(context).colorScheme.secondary,
              shape: StadiumBorder(),
              child: Text(S.of(context).apply_filters, textAlign: TextAlign.start, style: TextStyle(color: Theme.of(context).primaryColor)),
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
