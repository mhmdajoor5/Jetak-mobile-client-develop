import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../elements/SearchWidget.dart';

class SearchBarWidget extends StatelessWidget {
  final ValueChanged? onClickFilter;

  const SearchBarWidget({Key? key, this.onClickFilter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(SearchModal());
      },
      child: Container(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Color(0xFF292D32), size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                S.of(context).search_for_restaurants_or_foods,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                if (onClickFilter != null) {
                  onClickFilter!('e');
                }
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFEFF0F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.filter_alt_outlined, size: 20, color: Color(0xFF292D32)),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
