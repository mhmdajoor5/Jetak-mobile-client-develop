import 'package:flutter/material.dart';

class HtmlDescriptionWidget extends StatelessWidget {
  final String htmlContent;
  final TextStyle? textStyle;
  final double? maxHeight;

  const HtmlDescriptionWidget({
    Key? key,
    required this.htmlContent,
    this.textStyle,
    this.maxHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (htmlContent.isEmpty) {
      return const SizedBox.shrink();
    }

    // تنظيف HTML content من الـ entities وتحويله إلى نص عادي
    String cleanText = htmlContent
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'<[^>]*>'), '') // إزالة جميع HTML tags
        .trim();

    return Container(
      constraints: maxHeight != null 
          ? BoxConstraints(maxHeight: maxHeight!)
          : null,
      child: Text(
        cleanText,
        style: textStyle ?? TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
        maxLines: maxHeight != null ? 3 : null,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
