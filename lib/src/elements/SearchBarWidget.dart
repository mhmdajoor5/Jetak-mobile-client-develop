import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
            SvgPicture.asset(
              'assets/img/magnifyingGlass.svg',
              height: 24,
              width: 24,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                S.of(context).search_for_restaurants_or_foods,
                style: TextStyle(
                  color: Color(0xFFF9D9FA4),
                  fontSize: 15,
                  fontWeight: FontWeight.w400
                ),
              ),
            ),
            SizedBox(width: 10),
            Container(
              width: 1,
              height: 24,
              color: Color(0xFFD8D8D8),
            ),
            SizedBox(width: 5),
            InkWell(
              onTap: () {
                if (onClickFilter != null) {
                  onClickFilter!('e');
                }
              },
              child: Container(
                padding: EdgeInsets.all(8),
                child: SvgPicture.asset(
                  'assets/img/vector.svg',
                  height: 24,
                  width: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
