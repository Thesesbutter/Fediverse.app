import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/style.dart';
import 'package:logging/logging.dart';

var _logger = Logger("html_text_widget.dart");

class HtmlTextWidget extends StatelessWidget {
  final String data;
  final OnTap onLinkTap;
  final double fontSize;
  final FontWeight fontWeight;
  final double lineHeight;
  final Color color;
  final bool shrinkWrap;
  final bool drawNewLines;

  const HtmlTextWidget({
    @required this.data,
    @required this.onLinkTap,
    this.fontSize = 18.0,
    this.lineHeight = 1.0,
    this.fontWeight = FontWeight.normal,
    this.color,
    this.shrinkWrap = false,
    this.drawNewLines = true,
  });

  @override
  Widget build(BuildContext context) {
    String htmlData;
    if (drawNewLines) {
      // draw both new line types
      htmlData = data.replaceAll("\n", "</br>");
    } else {
      htmlData = data.replaceAll("\n", "");
      htmlData = data.replaceAll("<(/)*br>", "");
    }

    return Html(
      shrinkWrap: shrinkWrap,
      onImageTap: (String source) {
        _logger.finest(() => "onImageTap $source");
      },
      style: {
        "html": Style(
          //            backgroundColor: Colors.red,
          display: shrinkWrap ? Display.INLINE : Display.BLOCK,
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
//              alignment: Alignment.centerLeft,
//              textDecoration: null,
//              width: 0
        ),
        "body": Style(
          //            backgroundColor: Colors.grey,
          display: shrinkWrap ? Display.INLINE : Display.BLOCK,
//              alignment: Alignment.centerLeft,
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
//              width: 0
        ),
        "img": Style(display: Display.INLINE, width: 20, height: 20),
        "p": Style(
            height: lineHeight,
            display: Display.INLINE,
            fontSize: FontSize(fontSize),
            fontWeight: fontWeight,
            color: color),
      },
      onImageError: (exception, stackTrace) {
        _logger.warning(() => "onImageError", exception, stackTrace);
      },
      data: htmlData,
      onLinkTap: onLinkTap,
    );
  }
}
